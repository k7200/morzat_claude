# hooks — 任务完成自动通知

本目录包含 Claude Code 的 Hook 脚本，实现任务完成后自动采集结果并发送通知。

## 包含功能

### 1. notify-agi.sh — 核心通知脚本
- **触发时机**: Claude Code 的 Stop（生成停止）和 SessionEnd（会话结束）事件
- **功能流程**:
  1. 从 stdin 解析 session_id、cwd、event 等信息
  2. 30 秒防重复（Stop 和 SessionEnd 只处理第一个）
  3. 按优先级采集输出：task-output.txt → 备用文件 → 目录文件列表
  4. 读取 task-meta.json 获取任务名和通知目标
  5. 写入 latest.json 结果快照
  6. 通过 openclaw CLI 发送 Telegram/飞书通知
  7. 写入 pending-wake.json 供 AGI 主会话轮询

### 2. hook-config.json — 通知配置
- 结果文件输出目录、日志路径
- openclaw CLI 路径
- 输出采集参数（最大字符数、管道等待时间）
- 通知渠道配置（Telegram、飞书，可独立启停）

## 依赖

- **jq** — JSON 解析（必须）
- **openclaw** — 消息发送 CLI（可选，仅通知功能需要）

## 文件清单

| 文件 | 说明 |
|------|------|
| `notify-agi.sh` | 核心 hook 脚本 |
| `hook-config.json` | 通知渠道和采集参数配置 |
| `SETUP.md` | 一键部署 prompt |
