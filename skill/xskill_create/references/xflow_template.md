# xflow Skill 编写参考模板

## 1. Frontmatter 模板

```yaml
---
name: xflow_<kebab-case 名称>
version: "1.0"
tier: xflow
description: <一句话说明该 flow 做什么>
# 必填：声明依赖的 xtool skills
dependencies:
  - xtool:<skill-name-a>
  - xtool:<skill-name-b>
# 可选字段
input_schema:          # 输入参数及类型
  param_a: string      # 必填参数
  param_b?: number     # 可选参数（? 后缀）
output: <产出物描述>
triggers:              # 触发条件（可选）
  - "当用户要求 ..."
tags: [<分类标签>]
---
```

**必填**: name, version, tier, description, dependencies
**可选**: input_schema, output, triggers, tags

## 2. 结构约束

| 规则 | 说明 |
|------|------|
| 依赖方向 | xflow 只能引用 xtool，禁止引用其他 xflow 或 xtask |
| 调用方式 | 运行时通过 `Skill` tool 调用 xtool |
| 长度 | 100-250 行，超出需拆分 |
| 研究阶段 | 无强制 research phase |
| 自包含 | flow 逻辑自身完整，xtool 仅处理原子操作 |

## 3. xtool 依赖声明与调用

Frontmatter 中 `dependencies` 列出所有用到的 xtool。正文中调用格式：

```
步骤 N：调用 `xtool:<name>` 处理 <具体任务>
  - 传入：<参数说明>
  - 期望输出：<结果说明>
  - 失败处理：<降级/重试/终止>
```

调用时使用 Skill tool：`skill: "<xtool-skill-name>", args: "<参数>"`

## 4. 正文结构（按序，每 section 必须存在）

**4.1 触发条件** — 何时激活此 flow（1-3 条规则）

**4.2 流程 Phases** — 编号步骤，每个 phase 含：
- **名称**（动词开头）、**动作**（含 xtool 调用点）、**判断点**（if/else 或表格）、**输出**

**4.3 Decision Points** — 复杂分支用表格：

| 条件 | 动作 |
|------|------|
| A 且 B | 执行 phase 3 |
| !A | 终止，报告原因 |

**4.4 Guardrails** — 超时/失败 escalation、数据校验点、回滚条件

**4.5 输出规范** — 最终交付物的格式和内容要求

## 5. 写作风格

- 零废话，每句承载信息
- 步骤用祈使句（"提取"、"校验"、"调用"）
- 条件判断显式写出，不用"适当"、"酌情"等模糊词
- 每个 xtool 调用点标注失败处理
- 至少包含一个 minimal example

## 6. Minimal Example

```markdown
---
name: xflow_pr-review
version: "1.0"
tier: xflow
description: 自动化 PR review 流程
dependencies:
  - xtool:git-diff-reader
  - xtool:code-linter
input_schema:
  pr_url: string
output: review 报告（含问题列表和建议）
---

# PR Review Flow

## 触发条件
用户提供 PR URL 并要求 review。

## 流程

### Phase 1: 获取变更
调用 `xtool:git-diff-reader`
- 传入：pr_url
- 输出：changed_files, diff_content
- 失败：报错终止

### Phase 2: 静态检查
调用 `xtool:code-linter`
- 传入：changed_files
- 输出：lint_issues[]
- 失败：跳过，标记为"lint 未执行"

### Phase 3: 逻辑审查
逐文件分析 diff_content：
- 识别 bug 风险、性能问题、风格问题
- 结合 lint_issues 去重

| 问题严重度 | 处理 |
|-----------|------|
| Critical | 必须列出，标红 |
| Warning | 列出，给建议 |
| Info | 合并为一条总结 |

### Phase 4: 输出报告
格式：问题列表 + 总评（1-2 句）

## Guardrails
- diff 超过 2000 行：提示用户分批 review
- xtool 调用失败 2 次：终止该步骤，已完成部分照常输出
```

## 7. Anti-patterns

| 反模式 | 问题 | 正确做法 |
|--------|------|----------|
| 引用其他 xflow | 违反层级约束 | 只引用 xtool，复杂编排升级为 xtask |
| 内联原子逻辑 | flow 臃肿，不可复用 | 抽为 xtool 再引用 |
| 省略失败处理 | 流程脆弱 | 每个 xtool 调用点声明失败策略 |
| 模糊步骤（"适当处理"） | 不可执行 | 写明具体条件和动作 |
| 超 250 行 | 职责过重 | 拆分为多个 xflow 或升级 xtask |
| 无 example | 难以理解预期行为 | 至少一个 minimal example |
| dependencies 未声明 | 运行时找不到依赖 | frontmatter 列出全部 xtool |
