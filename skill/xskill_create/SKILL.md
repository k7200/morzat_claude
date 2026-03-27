---
name: xskill_create
description: 创建和修改 xskill（xtool/xflow/xtask 三层架构）。当用户要求创建 skill、写 skill、做一个新的工具/流程/任务封装时触发。也适用于用户说"帮我把这个流程变成 skill"、"封装一个 skill"、"写个 xtool/xflow/xtask"等场景。修改已有 xskill 时同样触发。
---

# xskill_create

创建高品质 xskill 的 xtask 级 skill。直出可用产物，不走 eval 迭代。

## xskill 三层架构

| 级别 | 前缀 | 引用规则 | 调研 | 定位 |
|------|------|----------|------|------|
| xtool | `xtool_` | 不引用任何 xskill | 不强制 | 原子工具能力 |
| xflow | `xflow_` | 仅引用 xtool | 不强制 | 流程封装 |
| xtask | `xtask_` | 引用任意级别；同级引用须开 SubAgent | 必须深度调研 | 解决复杂问题 |

## 工作流

### Step 1: 意图解析

从用户需求中提取：
1. **做什么** — skill 要赋予 Claude 什么能力
2. **何时触发** — 用户会怎么描述这个需求
3. **输出物** — skill 执行后产出什么

如果用户已指定级别（xtool/xflow/xtask），直接采用。否则按以下规则判断：

| 信号 | → 级别 |
|------|--------|
| 单一、无状态、不依赖其他 skill 的操作 | xtool |
| 多步流程、步骤间有顺序依赖、可调用现有 xtool | xflow |
| 需要领域知识、决策树、编排多个 skill、复杂度高 | xtask |

**跨级需求**：如果需求天然包含多个独立能力，拆成多个 xskill 分别创建。先创建低级别的，再创建依赖它们的高级别 skill。

### Step 2: 扫描已有 xskill

读取 `references/scan_xskills.md`，按其中的流程扫描、过滤、展示候选列表。用户确认后进入编写。

### Step 3: 判断存放位置

根据 skill 与当前 session 上下文的关系判断：

| 特征 | → 位置 | 路径 |
|------|--------|------|
| 领域相关、仅对当前项目有意义 | 项目级 | `.claude/skills/<name>/` |
| 通用能力、跨项目可复用 | 全局 | `~/.claude/skills/<name>/` |

判断后告知用户："这个 skill 我会放到 `<路径>`，因为 `<原因>`。"

### Step 4: 领域调研（仅 xtask）

xtask 必须在编写前完成深度调研。调研内容：
- 目标领域的主流工具、库、最佳实践
- 已有的相关 skill 或 MCP 的实现模式
- 常见 edge case 和失败模式
- 用户可能的变体需求

用 WebSearch + WebFetch + 项目文件阅读并行调研。调研结果写入 skill 的 `references/` 目录作为领域知识文档。

### Step 5: 编写 skill

根据级别读取对应模板：
- xtool → `references/xtool_template.md`
- xflow → `references/xflow_template.md`
- xtask → `references/xtask_template.md`

**编写原则**（所有级别通用）：

1. **精简** — 每行都要有存在价值。不写"请注意"、"需要强调"等废话
2. **解释 why** — 用理解驱动行为，而非堆砌 MUST/NEVER。如果写了 MUST，后面必须跟原因
3. **结构化决策** — 选择题用表格，条件逻辑用 `WHEN...THEN`，不用散文描述
4. **比例化详略** — 关键路径详写，辅助路径一句话或指向 reference
5. **有 guardrails** — 明确写"不要做什么"，比写"要做什么"更重要
6. **给 default path** — 推荐一条路径，仅说明何时偏离
7. **例子不可省** — 每个核心概念至少一个 example
8. **description 要 aggressive** — 在 frontmatter description 中明确列出触发场景，宁可过度触发不可漏触发

**依赖声明**（xflow/xtask）：

在 SKILL.md 正文中用专门的 `## 依赖` section 声明运行时依赖：

```markdown
## 依赖

| xskill | 级别 | 用途 |
|--------|------|------|
| xtool_pdf_extract | xtool | 提取 PDF 文本 |
| xflow_data_clean | xflow | 数据清洗流程 |
```

调用方式：在 skill 正文中指导 Claude 使用 `Skill` tool 调用依赖的 xskill。

**xtask 引用同级 xtask 时**，skill 正文中必须写明用 SubAgent 隔离：

```markdown
通过 Agent tool 启动 SubAgent 执行 xtask_xxx，隔离上下文避免污染。
```

### Step 6: 输出

产出完整的 skill 目录：

```
<name>/
├── SKILL.md
├── references/     （如有领域知识或大段参考）
├── scripts/        （如有确定性脚本）
└── assets/         （如有模板、图标等静态资源）
```

只创建需要的子目录。xtool 通常只有 SKILL.md。

### Step 7: 修改已有 xskill

当用户要修改（非升级）已有 xskill 时：
1. 读取当前 SKILL.md 完整内容
2. 理解修改意图
3. 保持原有 name 和级别不变
4. 应用编写原则进行修改
5. 如果修改涉及新增依赖，检查是否符合级别的引用规则

**不允许升级级别**。如果用户需求已超出当前级别的能力边界，建议创建新的高级别 xskill 来编排。

## Reference 文件索引

| 文件 | 何时读取 |
|------|----------|
| `references/xtool_template.md` | 编写 xtool 级 skill 时 |
| `references/xflow_template.md` | 编写 xflow 级 skill 时 |
| `references/xtask_template.md` | 编写 xtask 级 skill 时 |
| `references/scan_xskills.md` | Step 2 扫描已有 xskill 时 |
