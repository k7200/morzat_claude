# xskill_create — xskill 三层架构创建与修改

创建高品质 xskill 的 xtask 级 skill。支持 xtool/xflow/xtask 三层架构，直出可用产物。

## 功能

- 意图解析：自动判断 skill 级别（xtool/xflow/xtask）
- 扫描已有 xskill 并推荐可复用依赖
- 按级别读取对应模板编写 skill
- xtask 级别强制 domain research
- 支持修改已有 xskill（不允许升级级别）

## 文件清单

| 文件 | 说明 |
|------|------|
| `SKILL.md` | Skill 定义文件 |
| `references/scan_xskills.md` | xskill 扫描与发现流程 |
| `references/xtool_template.md` | xtool 编写模板 |
| `references/xflow_template.md` | xflow 编写模板 |
| `references/xtask_template.md` | xtask 编写模板 |

## 安装位置

`~/.claude/skills/xskill_create/`（用户级，所有项目可用）
