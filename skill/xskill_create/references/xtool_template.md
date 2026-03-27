# xtool 模板

一个 xtool 只做一件事。能用脚本固化的逻辑放 `scripts/`，SKILL.md 只写调用指令。

## Frontmatter

```yaml
---
name: xtool_<动词-名词>
tier: xtool
description: <一句话，≤80 字符>
---
```

## 约束

- 禁止引用其他 skill
- 禁止多阶段 workflow
- SKILL.md ≤ 80 行（脚本不计入）
- 单入口、单出口

## 结构

```
xtool_xxx/
├── SKILL.md        # 调用指令（极简）
└── scripts/        # 确定性逻辑固化（可选）
```

### SKILL.md 布局

```markdown
---
(frontmatter)
---

# 做什么（1 行）

## 用法
<!-- 输入参数、默认值 -->

## 逻辑
<!-- 核心规则，用 table/条件列表，不用散文 -->
<!-- 有 script 时：直接写"运行 scripts/xxx.py" -->

## 示例
<!-- 至少 1 个 input → output -->

## 不做
<!-- 显式边界 -->
```

无内容的 section 直接删除。

### scripts/ 用法

适合固化为脚本的场景：
- 文件格式转换、文本处理等确定性操作
- 需要第三方库的计算逻辑
- 重复执行且输出稳定的流程

SKILL.md 中这样调用：

```markdown
## 逻辑
运行 `${CLAUDE_SKILL_DIR}/scripts/convert.py`：
- 参数：`--input <file> --format json`
- 输出：转换后的文件写入同目录
- 失败：输出 stderr 并终止
```

## 示例

```yaml
---
name: xtool_extract-json
tier: xtool
description: 从非结构化文本提取 JSON 片段
---
```

```markdown
# 从文本中提取所有合法 JSON 片段

## 用法
输入文本，返回提取到的 JSON 数组。

## 逻辑
运行 `${CLAUDE_SKILL_DIR}/scripts/extract.py`：
- 参数：`--input <text_or_file>`
- 输出：`[{...}, {...}]`（JSON array）
- 无匹配时返回 `[]`

## 示例
输入: `日志里有 {"id":1} 和一些文字 {"id":2}`
→ `[{"id":1}, {"id":2}]`

## 不做
- 不校验 JSON schema
- 不修复 malformed JSON
```

## Anti-patterns

| 反模式 | 修正 |
|--------|------|
| 引用其他 skill | 内联或升级为 xflow |
| 超 80 行 SKILL.md | 逻辑移入 scripts/ |
| 散文写逻辑 | 改用 table/条件列表 |
| 无示例 | 补 input→output |
| 模糊输出 | 明确 schema |
