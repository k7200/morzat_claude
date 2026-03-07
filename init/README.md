# init — Claude Code 初始化配置

本目录包含 Claude Code 的基础配置文件，用于在新机器上快速初始化工作环境。

## 包含功能

### 1. StatusLine 自定义状态栏
- **文件**: `statusline-command.sh`
- **作用**: 在 Claude Code 底部状态栏展示：当前路径（黄色）、git 分支（绿色）、模型名 / token 消耗 / 上下文占比（亮蓝色）
- **效果**: `~/project <main>  Opus 4.6 | 5.2k | 15%`

### 2. settings.json 基础配置
- statusLine 指向 `statusline-command.sh`
- hooks 注册 Stop / SessionEnd 事件（配合 hooks 目录使用）

## 文件清单

| 文件 | 说明 |
|------|------|
| `statusline-command.sh` | 状态栏脚本，从 stdin 读取 JSON 并格式化输出 |
| `claude-code-statusline-prompt.md` | 状态栏部署 prompt |
| `SETUP.md` | 一键部署 prompt（包含 statusline + settings.json） |
