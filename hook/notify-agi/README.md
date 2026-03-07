# notify-agi — 任务完成自动通知

Claude Code 任务完成后自动采集结果并发送通知（Telegram / 飞书）。

## 功能

- **触发时机**: Stop（生成停止）和 SessionEnd（会话结束）
- **防重复**: 30 秒内重复触发自动跳过
- **输出采集**: task-output.txt → 备用文件 → 目录文件列表（按优先级）
- **通知发送**: 通过 openclaw CLI 发送到 Telegram / 飞书
- **结果写入**: latest.json（完整快照）+ pending-wake.json（AGI 轮询标记）

## 文件清单

| 文件 | 说明 |
|------|------|
| `notify-agi.sh` | 核心 hook 脚本 |
| `hook-config.json` | 通知渠道和采集参数配置 |
| `PROMPT.md` | 部署 prompt |

## 依赖

- **jq** — JSON 解析（必须）
- **openclaw** — 消息发送 CLI（可选，仅通知功能需要）

## 安装位置

- 脚本: `~/.claude/hooks/notify-agi.sh`
- 配置: `~/.claude/hooks/hook-config.json`
- 注册: `~/.claude/settings.json` 的 `hooks.Stop` 和 `hooks.SessionEnd`
