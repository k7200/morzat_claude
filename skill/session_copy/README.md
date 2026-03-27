# session_copy — iTerm2 批量开 tab

在 iTerm2 中批量打开 tab 并 cd 到当前目录，支持自动启动 Claude Code。

## 功能

- 批量打开 iTerm2 tab，所有 tab 自动 cd 到指定目录
- 第一个数字：打开 N 个 Claude tab（自动运行 `claude --dangerously-skip-permissions`，上限 5）
- 第二个数字（可选）：打开 N 个空白 tab（仅 cd，无上限）
- 通过 AppleScript 控制 iTerm2

## 文件清单

| 文件 | 说明 |
|------|------|
| `SKILL.md` | Skill 定义文件 |
| `scripts/spawn.sh` | AppleScript 批量开 tab 脚本 |

## 安装位置

`~/.claude/skills/session_copy/`（用户级，所有项目可用）
