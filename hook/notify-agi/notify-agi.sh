#!/bin/bash
# =============================================================================
# Claude Code Stop Hook — 任务完成自动回调通知
# =============================================================================
#
# 功能:
#   当 Claude Code 完成任务时，自动收集输出结果，通过配置的渠道
#   （Telegram / 飞书等）发送通知，并写入结果文件供 AGI 主会话读取。
#
# 触发时机:
#   - Stop       — Claude 生成停止（通常意味着任务完成）
#   - SessionEnd — 会话结束（兜底，防止 Stop 未触发时遗漏）
#
#   两个事件都会调用本脚本，内部通过 lock 文件做防重复处理。
#
# 依赖:
#   - jq          — JSON 解析（必须）
#   - openclaw    — 消息发送 CLI（可选，仅通知功能需要）
#
# 配置:
#   同目录下的 hook-config.json，详见各字段注释。
#
# =============================================================================

set -uo pipefail

# =============================================================================
# 第一步：加载配置
# =============================================================================
# 自动定位脚本所在目录，读取同目录下的 hook-config.json

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/hook-config.json"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "[ERROR] Config file not found: $CONFIG_FILE" >&2
    exit 1
fi

# cfg <jq_expression> — 从配置文件中提取值的快捷函数
cfg() { jq -r "$1" "$CONFIG_FILE" 2>/dev/null; }

# 路径与目录
RESULT_DIR="$(cfg '.result_dir')"              # 结果文件输出目录
LOG="$(cfg '.log_file')"                        # 日志文件路径
OPENCLAW_BIN="$(cfg '.openclaw_bin')"           # openclaw CLI 路径

# 输出采集
FALLBACK_OUTPUT_FILE="$(cfg '.fallback_output_file')"  # 备用输出文件路径
OUTPUT_MAX_CHARS="$(cfg '.output_max_chars')"           # 读取输出的最大字符数
PIPE_FLUSH_WAIT="$(cfg '.pipe_flush_wait')"             # 等待管道刷新的秒数

# 防重复
LOCK_AGE_LIMIT="$(cfg '.lock_age_limit')"       # N 秒内重复触发视为同一任务

# 通知
SUMMARY_MAX_CHARS="$(cfg '.summary_max_chars')"  # 通知消息中摘要截断长度
NOTIFY_CHANNELS_COUNT="$(jq '.notify_channels | length' "$CONFIG_FILE" 2>/dev/null || echo 0)"

# 派生路径
META_FILE="${RESULT_DIR}/task-meta.json"          # 任务元数据（由 dispatch 脚本写入）
TASK_OUTPUT="${RESULT_DIR}/task-output.txt"        # 任务输出（由 dispatch 脚本 tee 写入）
LOCK_FILE="${RESULT_DIR}/.hook-lock"               # 防重复 lock 文件
LATEST_FILE="${RESULT_DIR}/latest.json"            # 最新结果 JSON
WAKE_FILE="${RESULT_DIR}/pending-wake.json"        # AGI 唤醒标记文件

mkdir -p "$RESULT_DIR"

# log <message> — 带时间戳的日志写入
log() { echo "[$(date -Iseconds)] $*" >> "$LOG"; }

log "=== Hook fired ==="

# =============================================================================
# 第二步：解析 Claude Code 传入的事件信息
# =============================================================================
# Claude Code 通过 stdin 传入 JSON，包含 session_id、cwd、hook_event_name 等字段。
# 如果 stdin 是 tty（手动调试时）则跳过读取。

INPUT=""
if [ -t 0 ]; then
    log "stdin is tty, skip reading"
elif [ -e /dev/stdin ]; then
    INPUT=$(timeout 2 cat /dev/stdin 2>/dev/null || true)
fi

SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"' 2>/dev/null || echo "unknown")
CWD=$(echo "$INPUT"       | jq -r '.cwd // ""'              2>/dev/null || echo "")
EVENT=$(echo "$INPUT"      | jq -r '.hook_event_name // "unknown"' 2>/dev/null || echo "unknown")

log "session=$SESSION_ID cwd=$CWD event=$EVENT"

# =============================================================================
# 第三步：防重复触发
# =============================================================================
# Stop 和 SessionEnd 会在短时间内先后触发，只需处理第一个。
# 通过 lock 文件的修改时间判断：如果距上次触发不足 LOCK_AGE_LIMIT 秒则跳过。
#
# stat 兼容处理：Linux 用 -c %Y，macOS 用 -f %m

if [ -f "$LOCK_FILE" ]; then
    LOCK_TIME=$(stat -c %Y "$LOCK_FILE" 2>/dev/null \
             || stat -f %m "$LOCK_FILE" 2>/dev/null \
             || echo 0)
    NOW=$(date +%s)
    AGE=$(( NOW - LOCK_TIME ))

    if [ "$AGE" -lt "$LOCK_AGE_LIMIT" ]; then
        log "Duplicate hook within ${AGE}s (limit=${LOCK_AGE_LIMIT}s), skipping"
        exit 0
    fi
fi
touch "$LOCK_FILE"

# =============================================================================
# 第四步：采集 Claude Code 输出
# =============================================================================
# 按优先级依次尝试三个来源，取到即停：
#   1. task-output.txt — dispatch 脚本通过 tee 写入，最可靠
#   2. 备用输出文件    — 轻量启动脚本 run-claude-code.sh 写入的 fallback
#   3. 工作目录文件列表 — 最后兜底，至少能看到产出了哪些文件

OUTPUT=""

# 等待管道 flush：hook 可能在 tee 写完之前就被触发
sleep "$PIPE_FLUSH_WAIT"

# 来源 1: task-output.txt
if [ -f "$TASK_OUTPUT" ] && [ -s "$TASK_OUTPUT" ]; then
    OUTPUT=$(tail -c "$OUTPUT_MAX_CHARS" "$TASK_OUTPUT")
    log "Output source: task-output.txt (${#OUTPUT} chars)"
fi

# 来源 2: 备用输出文件
if [ -z "$OUTPUT" ] && [ -f "$FALLBACK_OUTPUT_FILE" ] && [ -s "$FALLBACK_OUTPUT_FILE" ]; then
    OUTPUT=$(tail -c "$OUTPUT_MAX_CHARS" "$FALLBACK_OUTPUT_FILE")
    log "Output source: fallback file (${#OUTPUT} chars)"
fi

# 来源 3: 工作目录文件列表
if [ -z "$OUTPUT" ] && [ -n "$CWD" ] && [ -d "$CWD" ]; then
    FILES=$(ls -1t "$CWD" 2>/dev/null | head -20 | tr '\n' ', ')
    OUTPUT="Working dir: ${CWD}\nFiles: ${FILES}"
    log "Output source: directory listing"
fi

# =============================================================================
# 第五步：读取任务元数据
# =============================================================================
# task-meta.json 由 dispatch-claude-code.sh 在启动任务时写入，
# 包含任务名和各渠道的通知目标。
# 格式示例: { "task_name": "xxx", "telegram_group": "-123", "feishu_group": "oc_abc" }
#
# META_TARGETS 关联数组：key 为渠道名，value 为该渠道的通知目标 ID。
# task-meta.json 中指定的 target 优先级高于 hook-config.json 中的默认值。

TASK_NAME="unknown"
declare -A META_TARGETS

if [ -f "$META_FILE" ]; then
    TASK_NAME=$(jq -r '.task_name // "unknown"' "$META_FILE" 2>/dev/null || echo "unknown")

    # 动态提取所有 *_group 字段，自动映射为渠道名 → target
    # 例如 telegram_group → META_TARGETS[telegram], feishu_group → META_TARGETS[feishu]
    while IFS='=' read -r key value; do
        [ -n "$key" ] && META_TARGETS["$key"]="$value"
    done < <(jq -r 'to_entries[] | select(.key | endswith("_group")) | "\(.key | sub("_group$";""))=\(.value // "")"' "$META_FILE" 2>/dev/null)

    log "Meta: task=$TASK_NAME targets=$(declare -p META_TARGETS 2>/dev/null | sed 's/.*(/(/;s/).*/)/') "
fi

# =============================================================================
# 第六步：写入结果 JSON
# =============================================================================
# latest.json 是本次任务的完整结果快照，供外部系统（AGI、监控面板等）读取。

jq -n \
    --arg sid "$SESSION_ID" \
    --arg ts "$(date -Iseconds)" \
    --arg cwd "$CWD" \
    --arg event "$EVENT" \
    --arg output "$OUTPUT" \
    --arg task "$TASK_NAME" \
    --arg tg_group "${META_TARGETS[telegram]:-}" \
    --arg fs_group "${META_TARGETS[feishu]:-}" \
    '{
        session_id: $sid,
        timestamp: $ts,
        cwd: $cwd,
        event: $event,
        output: $output,
        task_name: $task,
        telegram_group: $tg_group,
        feishu_group: $fs_group,
        status: "done"
    }' \
    > "$LATEST_FILE" 2>/dev/null

log "Wrote $LATEST_FILE"

# =============================================================================
# 第七步：遍历通知渠道，发送消息
# =============================================================================
# 从 hook-config.json 的 notify_channels 数组逐个处理：
#   - 跳过 enabled=false 的渠道
#   - target 优先取 task-meta.json 中的值，其次取配置文件中的默认值
#   - 两者都为空则跳过该渠道
#
# 消息格式统一，所有渠道共用同一段摘要内容。

SUMMARY=$(echo "$OUTPUT" | tail -c 1000 | tr '\n' ' ')
MSG="🤖 *Claude Code 任务完成*
📋 任务: ${TASK_NAME}
📝 结果摘要:
\`\`\`
${SUMMARY:0:$SUMMARY_MAX_CHARS}
\`\`\`"

for (( i = 0; i < NOTIFY_CHANNELS_COUNT; i++ )); do
    # 检查该渠道是否启用
    CH_ENABLED=$(jq -r ".notify_channels[$i].enabled" "$CONFIG_FILE" 2>/dev/null)
    [ "$CH_ENABLED" != "true" ] && continue

    CH_NAME=$(jq -r ".notify_channels[$i].channel" "$CONFIG_FILE" 2>/dev/null)
    CH_TARGET=$(jq -r ".notify_channels[$i].target"  "$CONFIG_FILE" 2>/dev/null)

    # task-meta.json 中的 target 覆盖配置文件默认值
    META_TARGET="${META_TARGETS[$CH_NAME]:-}"
    [ -n "$META_TARGET" ] && CH_TARGET="$META_TARGET"

    # 无 target 则无法发送
    if [ -z "$CH_TARGET" ]; then
        log "[$CH_NAME] No target configured, skipping"
        continue
    fi

    # 检查 openclaw CLI 是否可用
    if [ ! -x "$OPENCLAW_BIN" ]; then
        log "[$CH_NAME] openclaw not found at $OPENCLAW_BIN, skipping"
        continue
    fi

    # 发送通知
    if "$OPENCLAW_BIN" message send \
        --channel "$CH_NAME" \
        --target "$CH_TARGET" \
        --message "$MSG" 2>/dev/null; then
        log "[$CH_NAME] Sent to $CH_TARGET"
    else
        log "[$CH_NAME] Send failed (target=$CH_TARGET)"
    fi
done

# =============================================================================
# 第八步：写入 AGI 唤醒标记
# =============================================================================
# pending-wake.json 供 AGI 主会话在 heartbeat 轮询时读取。
# AGI 读取后应将 processed 置为 true 或删除此文件。

jq -n \
    --arg task "$TASK_NAME" \
    --arg tg_group "${META_TARGETS[telegram]:-}" \
    --arg fs_group "${META_TARGETS[feishu]:-}" \
    --arg ts "$(date -Iseconds)" \
    --arg summary "$(echo "$OUTPUT" | head -c 500 | tr '\n' ' ')" \
    '{
        task_name: $task,
        telegram_group: $tg_group,
        feishu_group: $fs_group,
        timestamp: $ts,
        summary: $summary,
        processed: false
    }' \
    > "$WAKE_FILE" 2>/dev/null

log "Wrote $WAKE_FILE"

# =============================================================================
# 完成
# =============================================================================

log "=== Hook completed ==="
exit 0
