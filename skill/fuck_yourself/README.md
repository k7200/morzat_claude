# fuck_yourself — 方向性质疑自我反省

用户对产出提出方向性质疑时，执行结构化自我反省流程：还原现场 → 归因 → 泛化 → 确认 → 存档 → 更新 CLAUDE.md → 沉淀 memory。

## 功能

- 区分方向性质疑 / 细节修订 / 偏好表达，仅方向性质疑触发
- 五级归因：规则缺失 → 规则模糊 → 规则冲突 → 规则过窄 → 执行偏差
- 泛化为通用原则，经用户确认后写入项目 CLAUDE.md
- 自动备份 CLAUDE.md 版本历史到 `.claude/claude_history/`

## 文件清单

| 文件 | 说明 |
|------|------|
| `SKILL.md` | Skill 定义文件 |

## 安装位置

`~/.claude/skills/fuck_yourself/`（用户级，所有项目可用）
