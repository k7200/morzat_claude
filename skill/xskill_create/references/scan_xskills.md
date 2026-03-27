# xskill 扫描与发现流程

## 1. 扫描位置

| 作用域 | 路径 | 优先级 |
|--------|------|--------|
| global | `~/.claude/skills/` | 低 |
| project | `.claude/skills/` (项目根目录) | 高（同名覆盖 global） |

扫描命令：

```bash
# 两个目录下递归查找 SKILL.md，提取所属目录名匹配 xtool_/xflow_/xtask_ 前缀
for dir in ~/.claude/skills .claude/skills; do
  find "$dir" -maxdepth 2 -name "SKILL.md" 2>/dev/null | while read f; do
    basename "$(dirname "$f")"
  done
done | grep -E '^x(tool|flow|task)_' | sort -u
```

无 `SKILL.md` 的目录跳过。project-level 同名 skill 覆盖 global-level。

## 2. 解析 Frontmatter

从每个 `SKILL.md` 提取 YAML frontmatter（`---` 包围的首块）：

| 字段 | 提取方式 | 必填 |
|------|---------|------|
| name | frontmatter `name` | Y |
| tier | frontmatter `tier`；若缺失则从目录名前缀推断：`xtool_` → xtool, `xflow_` → xflow, `xtask_` → xtask | Y |
| description | frontmatter `description` | Y |
| version | frontmatter `version` | N |
| tags | frontmatter `tags` | N |

tier 推断规则：目录名前缀 **优先级低于** frontmatter 显式声明。两者冲突时以 frontmatter 为准并输出警告。

## 3. 依赖候选过滤

新建 skill 的 tier 决定可引用范围：

| 新 skill tier | 可引用 | 不可引用 |
|---------------|--------|---------|
| xtool | （无） | xtool, xflow, xtask |
| xflow | xtool | xflow, xtask |
| xtask | xtool, xflow, xtask* | — |

> *xtask 引用 xtask 须通过 SubAgent 隔离调用。

过滤逻辑：
1. 取全量 xskill 列表
2. 按上表过滤，仅保留当前 tier 可引用的 skill
3. 结果即为 dependency candidate list

## 4. 推荐呈现

向用户展示候选列表时：
- 按 tier 分组（xtool → xflow → xtask）
- 每组内按 name 字母序
- 标注 scope（global/project）
- 功能重叠的 skill 加 `[推荐复用]` 标记（基于 description 关键词与当前任务匹配）

## 5. 输出格式

```yaml
available_xskills:
  - tier: xtool
    name: xtool_extract-json
    description: "从非结构化文本提取 JSON"
    scope: global
    reuse: recommended  # recommended | available | restricted
  - tier: xflow
    name: xflow_doc-pipeline
    description: "文档生成编排流程"
    scope: project
    reuse: available
```

| reuse 值 | 含义 |
|----------|------|
| recommended | description 与当前任务高度相关，建议复用 |
| available | tier 规则允许引用，按需使用 |
| restricted | tier 规则禁止引用（仅在完整列表模式下展示） |

## 6. 快速参考

```
扫描 → 解析 frontmatter → 按 tier 过滤 → 标记推荐 → 输出 YAML 列表
```

全流程应在单次工具调用内完成，不需用户介入。
