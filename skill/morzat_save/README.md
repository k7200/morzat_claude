# morzat_save — Claude Code 功能归档 Skill

一键将本地的 Claude Code 功能（skill、mcp、hook、statusline 等）归档到 morzat_claude Git 仓库，自动生成文档并 commit & push。

## 功能

- 根据用户描述，自动定位源文件（~/.claude/ 下的配置、脚本等）
- 复制到 morzat_claude 仓库的对应分类目录
- 自动生成/更新 README.md（功能说明）和 SETUP.md（部署 prompt）
- 自动 git commit + push

## 用法

```
/morzat_save 把我的 statusline 配置保存下来
/morzat_save 保存 hook 通知脚本
```

## 文件清单

| 文件 | 说明 |
|------|------|
| `SKILL.md` | Skill 定义文件（含 YAML frontmatter） |

## 安装位置

`~/.claude/skills/morzat_save/SKILL.md`（用户级，所有项目可用）
