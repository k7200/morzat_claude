# morzat_save 部署 Prompt

将以下内容发送给 Claude Code 即可部署:

---

## Prompt

```
帮我创建一个用户级 Claude Code skill，用于将本地 Claude Code 功能归档到 Git 仓库。

### 1. 创建 skill 文件

路径: ~/.claude/skills/morzat_save/SKILL.md

YAML frontmatter:
- name: morzat_save
- description: 将 Claude Code 功能（skill、mcp、hook 等）归档到 morzat_claude 仓库
- user-invocable: true
- argument-hint: <要保存的功能描述>

Skill 内容要求:
- 接收用户通过 $ARGUMENTS 传入的功能描述
- 仓库默认路径 ~/morzat_claude，不存在则 git clone 或 git init
- 根据用户描述定位源文件，常见位置包括:
  - ~/.claude/statusline-command.sh（statusline）
  - ~/.claude/hooks/（hooks）
  - ~/.claude/settings.json（settings）
  - ~/.claude/mcp.json 或 .mcp.json（MCP）
  - ~/.claude/skills/ 或 .claude/commands/（skills）
  - CLAUDE.md
- 在仓库中按功能分类存放到对应目录（init/statusline、hook、skill、mcp 等）
- 每个功能目录必须有两个文档:
  - README.md: 功能说明、文件清单、依赖
  - SETUP.md: 可直接复制执行的部署 prompt（描述需求而非贴源码）
- 已存在的目录和文档执行更新而非重写
- 完成后自动 git add -A（排除 .DS_Store）、生成中文 commit message、git commit、git push
- 最后输出摘要: 保存了什么、文件列表、commit hash、push 状态
```
