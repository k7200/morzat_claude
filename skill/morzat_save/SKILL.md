---
name: morzat_save
description: 将 Claude Code 功能（skill、mcp、hook 等）归档到 morzat_claude 仓库
user-invocable: true
argument-hint: <要保存的功能描述>
---

将用户指定的 Claude Code 功能归档到 morzat_claude 仓库，配上 README.md 和 SETUP.md，然后 commit & push。

用户输入: $ARGUMENTS

## 仓库位置

- 默认路径: ~/morzat_claude
- 如果目录不存在，先执行 `git clone`（提示用户提供 remote 地址）
- 如果 clone 也不可行，就地 `git init` 并提示用户后续添加 remote

## 步骤

### 1. 定位源文件

根据用户描述，找到对应的源文件。常见位置:
- statusline: ~/.claude/statusline-command.sh
- hooks: ~/.claude/hooks/
- settings: ~/.claude/settings.json
- MCP: ~/.claude/mcp.json 或项目级 .mcp.json
- skills/commands: ~/.claude/commands/ 或 .claude/skills/
- CLAUDE.md: ~/.claude/CLAUDE.md 或项目级 CLAUDE.md

读取这些文件，理解其功能。

### 2. 确定目标目录

在 ~/morzat_claude 中按功能分类存放，目录命名用英文单数:
- init/statusline — 状态栏配置
- init/claude_md — CLAUDE.md 相关
- init/soul_md — 人格/系统提示词
- hook — hooks 相关
- skill — 自定义 slash commands
- mcp — MCP server 配置

已存在则更新，不存在则新建。

### 3. 复制文件

将源文件复制到对应目录，保留原始文件名。

### 4. 编写/更新 README.md

每个功能目录必须有 README.md:
- 一级标题: 目录名 + 一句话描述
- 包含功能: 列出每个文件的作用
- 文件清单: 表格形式
- 依赖说明（如有）

已存在则更新，不要全部重写。

### 5. 编写/更新 SETUP.md

每个功能目录必须有 SETUP.md，这是一份部署 prompt:

```
# <目录名> 部署 Prompt

将以下内容发送给 Claude Code 即可部署:

---

## Prompt

（完整的、可直接复制给 Claude Code 执行的 prompt，
  描述如何从零创建和配置这些文件。
  描述功能需求而非直接贴源码。
  路径中的 ~ 要提示替换为实际绝对路径。）
```

已存在则更新。

### 6. 提交并推送

1. `cd ~/morzat_claude`
2. `git add -A`（排除 .DS_Store）
3. 中文 commit message: 新增用 `新增: <功能名>`，更新用 `更新: <功能名>`
4. `git commit`
5. 有 remote 则 `git push`（首次 `-u`），无 remote 则提示用户添加
6. 输出摘要: 保存了什么、文件列表、commit hash、push 状态
