# xtask Skill 模板参考

最复杂的 skill 层级。解决需要 research、决策、多步编排的真实问题。

## 1. Frontmatter 模板

```yaml
---
name: xtask_<kebab-case 名称>
version: 0.1.0
tier: xtask
description: <一句话说明解决什么问题>

# 依赖声明 — 三层级均可引用
dependencies:
  xtool:            # 原子工具
    - name: json-parser
      version: ">=1.0"
    - name: file-writer
  xflow:            # 工作流
    - name: ci-pipeline
      version: ">=2.0"
  xtask:            # 其他 xtask — 必须 SubAgent 调用
    - name: security-audit
      isolation: subagent    # 强制字段
      version: ">=1.0"

# xtask 必填
research_required: true
estimated_lines: 150-400
timeout_minutes: 30

# 可选
tags: [domain-tag]
escalation_contact: "<角色或频道>"
---
```

**必填字段**: `name`, `tier: xtask`, `description`, `dependencies`, `research_required`
**可选字段**: `version`, `tags`, `timeout_minutes`, `escalation_contact`

## 2. 结构约束

| 约束 | 要求 |
|------|------|
| 行数 | 150-400 行 |
| domain research | 必须有独立 section，在执行前完成 |
| decision tree | 核心逻辑必须用显式决策树 |
| SubAgent 隔离 | 调用其他 xtask 时强制使用 |
| failure mode | 每个关键步骤必须声明 |
| example | 至少一个最小可运行示例 |

## 3. 多层级依赖声明规则

- **xtool**: 直接内联调用，无隔离要求
- **xflow**: 直接调用，传参遵循 xflow 的 input schema
- **xtask**: **禁止直接调用**，必须 SubAgent/AgentTeam 包装，确保 context 隔离

```
xtool  → 直接调用（函数级）
xflow  → 直接调用（workflow 级）
xtask  → SubAgent 隔离调用（agent 级）
```

## 4. SubAgent 隔离 Pattern

xtask 调用另一个 xtask 时，必须遵循：

```markdown
### SubAgent 调用: <被调用 xtask 名>

**隔离要求**:
- 独立 context window，不共享父任务状态
- 通过结构化 input/output 通信
- 超时设置独立于父任务

**调用模板**:
调用 SubAgent 执行 `<xtask-name>`：
- Input: { <明确的输入参数> }
- Expected output: { <期望的输出结构> }
- Timeout: <N> min
- On failure: <降级策略>

**结果处理**:
- 成功 → 提取关键字段继续
- 部分成功 → 记录偏差，评估是否可继续
- 失败 → 执行降级策略或 escalate
```

## 5. Domain Research Section 要求

每个 xtask **必须**以 research 开头，且在任何执行动作之前完成。

```markdown
## Phase 0: Domain Research

> 在做任何修改前，必须完成以下调研。

### 调研清单
- [ ] <调研项 1>: 目标、方法、产出
- [ ] <调研项 2>: ...

### 调研方法
- 代码库: Grep/Glob 搜索 pattern
- 文档: 读取相关 README、ADR、RFC
- 运行时: 执行诊断命令收集状态

### 调研产出
输出结构化发现，作为后续决策的输入依据。
不得跳过。调研不充分时禁止进入执行阶段。
```

## 6. Section 布局指南

```
---（frontmatter）---

## 概述（2-3 行：问题 + 方案概要）

## Phase 0: Domain Research（必须）
  - 调研清单 / 方法 / 产出格式

## Phase 1: 分析与决策
  ### Decision Tree（核心 — 用缩进或流程图）
  ```
  IF <条件A>
    → 路径1: <动作>
    IF <子条件>
      → 路径1a / 路径1b
  ELIF <条件B>
    → 路径2: <动作>
  ELSE
    → ESCALATE: <原因>
  ```

## Phase 2: 执行
  - 按决策结果分步执行
  - 每步标注: 调用的 xtool/xflow/xtask + failure mode

## Phase 3: 验证
  - 验收标准 checklist
  - 回归检查

## Guardrails & Escalation
  - 硬性边界（不可逾越）
  - 软性边界（可协商）
  - Escalation 触发条件和路径

## Example（最小可运行示例）
```

## 7. 写作风格规则

- **关键路径详写，boilerplate 略写** — research 和决策树是重心
- **决策树必须显式** — 禁止 "根据情况判断" 这类模糊表述
- **每个分支有明确动作** — 包含具体要调用的 skill 或命令
- **failure mode 紧跟每个关键步骤** — 不要集中到末尾
- **guardrail 前置** — 在概述后、执行前说明边界
- **中文解释，英文术语** — 如 "使用 SubAgent 进行 context 隔离"

## 8. 最小示例

```markdown
---
name: xtask_api-migration
tier: xtask
description: 将 REST API 从 v2 迁移到 v3，含 breaking change 分析
dependencies:
  xtool: [{ name: ast-parser }, { name: test-runner }]
  xflow: [{ name: ci-pipeline }]
  xtask: [{ name: security-audit, isolation: subagent }]
research_required: true
---

## 概述
分析 v2→v3 breaking changes，自动迁移可转换端点，标记需人工处理的端点。

## Phase 0: Domain Research
- Grep `@deprecated` 和 `v2` route 定义
- 读取 API changelog 和 migration guide
- 统计各端点调用频率（从日志或监控）

## Phase 1: 决策
IF endpoint 有 1:1 v3 对应 → 自动迁移（ast-parser 重写）
ELIF endpoint 可通过 adapter 兼容 → 生成 adapter 层
ELSE → 标记为 manual，输出迁移指南

## Phase 2: 执行
1. 调用 `ast-parser` 批量重写自动迁移端点
2. 生成 adapter 代码（模板化）
3. SubAgent 调用 `security-audit` 扫描新端点
   - Input: { endpoints: <迁移后列表> }
   - On failure: 阻断发布，报告安全问题
4. 调用 `ci-pipeline` 运行全量测试

## Phase 3: 验证
- [ ] 所有 v2 端点有处置方案
- [ ] 自动迁移端点测试通过
- [ ] security-audit 无 critical 发现

## Guardrails
- 硬性: 不删除有流量的 v2 端点
- Escalate: 超过 20% 端点需 manual 处理时暂停
```

## 9. Anti-patterns

| Anti-pattern | 问题 | 正确做法 |
|---|---|---|
| 跳过 research 直接执行 | 错误假设导致返工 | 强制 Phase 0 |
| 直接调用另一个 xtask | context 污染，状态泄漏 | SubAgent 隔离 |
| 模糊决策（"视情况而定"） | Claude 无法执行 | 显式 IF/ELIF/ELSE |
| failure mode 集中在末尾 | 失败时找不到对应处理 | 紧跟关键步骤后 |
| 400+ 行巨型 skill | 超出有效 context | 拆分为 xtask + xflow 组合 |
| 无 example | 缺乏具象理解 | 至少一个最小示例 |
| research 产出无结构 | 后续步骤无法引用 | 结构化输出（表格/清单） |
| guardrail 缺失 | 无边界约束导致越界 | 前置声明硬性/软性边界 |
