# User Global Rules

## 沟通规范
- 术语英文，其余中文
- 拒绝与项目 CLAUDE.md 角色无关的提问，引导开新对话
- 简洁直接，不复述，不加过渡语
- 文件变更先说意图再执行

## 输出规范
- 任务启动时，在当前目录下创建工作区：`<MMDD>_<任务名称>/`
- 任务名称：2-4 个英文单词，snake_case（如 `0317_feishu_doc_gen/`）
- 所有产物必须放在工作区内
- 所有文件名用 `_` 分隔，不用 `-`
- 执行流图用 PlantUML，同时输出 `.puml` 源文件和对应 `.svg`
- 数据图表用 ECharts，同时输出 `.echarts.json` 配置和对应 `.svg`
- 图表 SVG 以相对路径嵌入 md 文件：`![描述](./assets/xxx.svg)`

## 任务工作流

### Phase 1: Plan
**Size 分级**

| Size | 时间 | 要求 |
|------|------|------|
| Small | < 2 min | 口头 plan → 直接执行，跳过后续 Plan 步骤 |
| Large | 2-30 min | 完整 Plan，task tree 最多 3 层 |
| Super | > 30 min | 完整 Plan，task tree 最多 4 层 |

**任务拆解（Large/Super）**
- 拆为 subtask tree 写入工作区下的 `plan.md`（含 size、tree、风险点），叶子节点为原子任务
- subtask 完成后在 `plan.md` 对应条目前标 ✅
- 依赖关系输出为 DAG 图：`assets/dag.puml` + `assets/dag.svg`，嵌入 `plan.md`
- `plan.md` 和 DAG 图任务完成后保留；执行中有变更须同步更新
- 用户确认 plan 后进入执行阶段

### Phase 2: Execute
- subAgent 并行无依赖 subtask，最大并发 8
- 按 DAG 拓扑序调度
- 每个 subtask 完成后汇报：✅ / ⚠️ 有偏差 / ❌ 失败
- Large/Super：每个 milestone 做阶段性汇报
- subtask 连续失败 2 次或超预估 2 倍：暂停该 subtask，求助用户，不阻塞其他任务
- 需求偏差：回 Phase 1 修正 plan
- Super 任务按 milestone 设 checkpoint；方向性错误 rollback 到上一 checkpoint

### Phase 3: Review
- 回溯用户全部原始输入，逐条核对交付物
- 代码过 lint / type check / test；文档检查格式和链接；配置不破坏现有环境
- 输出总结：各 subtask 实现方式（一句话）、关键文件变更、未完成项
- 用户对产出提出方向性质疑（非细节修订，而是指出思路、原则层面的问题）时，调用 `/fuck_yourself` 执行自我反省

### Phase 4: Retrospective
Large/Super 必须执行。Small 仅在出现意外时执行。
- 分析失败 root cause，可复用经验写入 memory
- 识别耗时超预期的 subtask，优化模式记录到 memory
- 满足以下条件时沉淀为 skill（`tmp/skills/`）：重复 2 次以上、可参数化、能显著提效
