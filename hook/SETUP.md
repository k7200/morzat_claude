# hooks 部署 Prompt

将以下内容发送给 Claude Code 即可部署 hooks 通知系统：

---

## Prompt

```
帮我配置 Claude Code 的任务完成自动通知 hook，按以下步骤操作：

### 1. 创建 ~/.claude/hooks/ 目录

### 2. 创建 ~/.claude/hooks/hook-config.json

内容如下（路径按实际环境调整）：

{
  "result_dir": "~/.claude/hooks/results",
  "log_file": "~/.claude/hooks/results/hook.log",
  "openclaw_bin": "/usr/local/bin/openclaw",
  "fallback_output_file": "/tmp/claude-code-output.txt",
  "lock_age_limit": 30,
  "output_max_chars": 4000,
  "summary_max_chars": 800,
  "pipe_flush_wait": 1,
  "notify_channels": [
    {
      "channel": "telegram",
      "target": "",
      "enabled": true
    },
    {
      "channel": "feishu",
      "target": "",
      "enabled": false
    }
  ]
}

### 3. 创建 ~/.claude/hooks/notify-agi.sh

创建一个 bash 脚本，功能如下：

- 从同目录的 hook-config.json 读取所有配置
- 从 stdin 读取 Claude Code 传入的 JSON，解析 session_id、cwd、hook_event_name
- 防重复：用 lock 文件实现，lock_age_limit 秒内重复触发跳过
- 采集输出（按优先级）：
  1. result_dir/task-output.txt
  2. fallback_output_file
  3. 工作目录文件列表（兜底）
- 读取 result_dir/task-meta.json 获取任务名和各渠道 target（*_group 字段自动映射为渠道名）
- 写入 result_dir/latest.json：包含 session_id、timestamp、cwd、event、output、task_name、status
- 遍历 notify_channels：跳过 enabled=false 的；target 优先取 task-meta.json 中的值；用 openclaw message send 发送通知
- 写入 result_dir/pending-wake.json：供 AGI 主会话轮询读取
- 全程写日志到 log_file

脚本需要 chmod +x。

### 4. 在 ~/.claude/settings.json 中注册 hooks

合并以下配置到现有 settings.json（不要覆盖已有内容）：

{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "<绝对路径>/.claude/hooks/notify-agi.sh",
            "timeout": 10
          }
        ]
      }
    ],
    "SessionEnd": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "<绝对路径>/.claude/hooks/notify-agi.sh",
            "timeout": 10
          }
        ]
      }
    ]
  }
}

command 中的路径用实际的 $HOME 绝对路径替换。
```
