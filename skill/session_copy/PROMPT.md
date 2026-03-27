# session_copy 部署 Prompt

将以下内容发送给 Claude Code 即可部署:

---

## Prompt

请在 `~/.claude/skills/session_copy/`（替换 `~` 为实际路径）创建一个 skill + 配套 bash 脚本，功能是在 iTerm2 中批量打开 tab。

核心设计：
1. **用法**：`/session_copy 3` 或 `/session_copy 3,2`（第一个数字=Claude tab 数量上限5，第二个数字=空白 tab 数量无上限）
2. **Claude tab**：cd 到目标目录后自动运行 `claude --dangerously-skip-permissions`
3. **空白 tab**：仅 cd 到目标目录
4. **实现**：bash 脚本通过 `osascript` 调用 AppleScript 控制 iTerm2，创建 tab 并写入命令
5. **脚本路径**：`scripts/spawn.sh`，接收三个参数：`<claude_count> <plain_count> "<target_directory>"`
6. **SKILL.md 负责**：解析用户输入（任意非数字分隔符）、截断上限、调用脚本、汇报结果
