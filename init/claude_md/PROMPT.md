# claude_md 部署 Prompt

将以下内容发送给 Claude Code 即可部署:

---

## Prompt

请在 `~/.claude/CLAUDE.md`（注意替换 `~` 为实际绝对路径）创建用户级全局规则文件，包含以下功能模块：

1. **沟通规范**：术语英文其余中文、拒绝无关提问引导开新对话、简洁直接不复述、文件变更先说意图再执行

2. **输出规范**：
   - 任务启动时创建 `<MMDD>_<任务名称>/` 工作区（snake_case，2-4 个英文单词）
   - 文件名用 `_` 分隔
   - 执行流图用 PlantUML（`.puml` + `.svg`）
   - 数据图表用 ECharts（`.echarts.json` + `.svg`）
   - 图表 SVG 以相对路径嵌入 md

3. **四阶段任务工作流**：
   - Phase 1 Plan：Small(<2min 口头plan直接执行) / Large(2-30min 完整plan+3层task tree) / Super(>30min 完整plan+4层task tree)，subtask tree 写入 `plan.md`，依赖关系输出 DAG 图
   - Phase 2 Execute：SubAgent 并行无依赖 subtask（最大并发8），按 DAG 拓扑序调度，连续失败2次暂停求助
   - Phase 3 Review：回溯原始输入逐条核对，代码过 lint/test，输出总结；方向性质疑时调用 `/fuck_yourself`
   - Phase 4 Retrospective：Large/Super 必须执行，分析 root cause，满足条件时沉淀为 skill
