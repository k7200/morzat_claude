# xskill_create 部署 Prompt

将以下内容发送给 Claude Code 即可部署:

---

## Prompt

请在 `~/.claude/skills/xskill_create/`（替换 `~` 为实际路径）创建一个 xtask 级 skill，功能是创建和修改 xskill。

核心设计：
1. **三层架构**：xtool（原子工具，不引用任何 xskill）→ xflow（流程封装，仅引用 xtool）→ xtask（复杂编排，引用任意级别，同级须 SubAgent 隔离）
2. **七步工作流**：意图解析 → 扫描已有 xskill → 判断存放位置（项目级/全局） → 领域调研（仅 xtask） → 编写 skill → 输出目录 → 修改已有 xskill
3. **编写原则**：精简、解释 why、结构化决策、比例化详略、有 guardrails、给 default path、例子不可省、description 要 aggressive
4. **四个 reference 文件**：`scan_xskills.md`（扫描流程）、`xtool_template.md`（≤80行，单入口单出口）、`xflow_template.md`（100-250行，只依赖 xtool）、`xtask_template.md`（150-400行，强制 research + 显式决策树）
5. **触发场景**：创建 skill、写 skill、封装 skill、写 xtool/xflow/xtask、把流程变成 skill
