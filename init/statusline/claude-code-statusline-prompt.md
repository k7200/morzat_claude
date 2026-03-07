# Claude Code Statusline 配置 Prompt

将以下内容发送给 Claude Code 即可一键配置 statusline：

---

## Prompt

```
帮我配置 Claude Code 的 statusline，要求如下：

1. 创建脚本文件 ~/.claude/statusline-command.sh，内容如下：

- 从 stdin 读取 Claude Code 传入的 JSON（通过 cat 读取）
- 用 jq 提取以下字段：
  - 当前目录：.workspace.current_dir // .cwd
  - 模型名：.model.display_name
  - 上下文使用百分比：.context_window.used_percentage
  - 输入 token 数：.context_window.total_input_tokens
  - 输出 token 数：.context_window.total_output_tokens

- 展示格式（左右两部分，中间用空格分隔）：
  左侧：路径 <git分支>
  右侧：模型名 | token总量 | 上下文百分比%

- 颜色方案（ANSI 转义码）：
  - 路径：黄色加粗 \033[1;33m
  - git 分支（含尖括号 <>）：绿色加粗 \033[1;32m
  - 右侧所有信息（模型名、token、百分比、分隔符 |）：亮蓝色加粗 \033[1;36m

- 路径处理：将 $HOME 前缀替换为 ~（注意不要用 \~ 避免 printf %b 输出反斜杠）

- git 分支获取：用 GIT_OPTIONAL_LOCKS=0 避免阻塞，先尝试 symbolic-ref --short HEAD，失败则 rev-parse --short HEAD；不在 git 仓库时不显示分支部分

- token 总量 = total_input_tokens + total_output_tokens，格式化规则：
  - < 1000：显示原始数字
  - >= 1000：显示为 x.xk（如 5.2k）
  - >= 1000000：显示为 x.xm（如 1.2m）
  - 用 awk 做浮点格式化

- 上下文百分比：取整后加 % 后缀（直接用 % 字符，不要用 %%）

- 最终用 printf "%b  %b\n" 输出左右两部分

2. 在 ~/.claude/settings.json 中添加 statusLine 配置：

{
  "statusLine": {
    "type": "command",
    "command": "bash ~/.claude/statusline-command.sh"
  }
}

注意 command 中的路径用 ~/.claude/statusline-command.sh（用实际的绝对路径替换 ~）。
```

---

## 最终效果示例

```
~/Desktop/claude <main>  Opus 4.6 | 5.2k | 15%
```
