# skill — Claude Code 自定义技能

本目录存放 Claude Code 的自定义 slash commands（技能），每个子目录对应一个 skill。

## 已有 Skills

| 名称 | 说明 | 用法 |
|------|------|------|
| [morzat_save](morzat_save/) | 将 Claude Code 功能归档到 morzat_claude 仓库 | `/morzat_save <描述>` |
| [xskill_create](xskill_create/) | 创建和修改 xskill（xtool/xflow/xtask 三层架构） | 描述需求即可触发 |
| [fuck_yourself](fuck_yourself/) | 方向性质疑时自我反省并更新 CLAUDE.md | `/fuck_yourself <质疑内容>` |
| [session_copy](session_copy/) | iTerm2 批量开 tab 并 cd 到当前目录 | `/session_copy 3,2` |

## 安装方式

将子目录中的 `SKILL.md` 复制到 `~/.claude/skills/<skill名>/SKILL.md` 即可。
