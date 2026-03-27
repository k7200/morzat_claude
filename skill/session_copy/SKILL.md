---
name: session_copy
description: "在 iTerm2 中批量打开 tab 并 cd 到当前目录。用户想要复制/克隆/批量打开 iTerm 会话、开多个终端 tab、或批量创建终端工作区时使用此 skill。触发短语包括：'开 tab'、'复制会话'、'spawn terminals'、'copy session'、'clone iterm'、'开几个窗口' 等。"
---

# Session Copy

在 iTerm2 中批量打开 tab，所有新 tab 自动 cd 到当前工作目录。

## 用法

用户提供一个或两个数字，用任意非数字字符分隔（空格、逗号、斜杠、`+` 等均可）：

```
/session_copy 3
/session_copy 3,2
/session_copy 3/2
/session_copy 3 2
```

- **第一个数字**（必填）：打开 N 个 tab，cd 到当前目录并自动运行 `claude --dangerously-skip-permissions`。上限 5 个。
- **第二个数字**（选填）：打开 N 个 tab，仅 cd 到当前目录，不运行任何命令。无上限。

## 执行步骤

1. 解析用户输入，提取两个数字。以任意非数字字符为分隔符。若只有一个数字，第二个默认为 0。
2. 第一个数字超过 5 时自动截断为 5，并告知用户上限。
3. 运行内置脚本：

```bash
bash ~/.claude/skills/session_copy/scripts/spawn.sh <claude_count> <plain_count> "<target_directory>"
```

第三个参数是当前工作目录，必须显式传入。

4. 汇报结果："已打开 X 个 Claude tab + Y 个空白 tab，目录：`<dir>`"
