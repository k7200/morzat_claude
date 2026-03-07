# init 部署 Prompt

将以下内容发送给 Claude Code 即可完成初始化配置：

---

## Prompt

```
帮我配置 Claude Code 的初始化环境，按以下步骤操作：

### 1. 创建状态栏脚本 ~/.claude/statusline-command.sh

创建脚本，功能如下：
- 从 stdin 读取 Claude Code 传入的 JSON（通过 cat）
- 用 jq 提取字段：
  - 当前目录：.workspace.current_dir // .cwd
  - 模型名：.model.display_name
  - 上下文使用百分比：.context_window.used_percentage
  - 输入 token：.context_window.total_input_tokens
  - 输出 token：.context_window.total_output_tokens

- 展示格式（左右两部分）：
  左侧：路径 <git分支>
  右侧：模型名 | token总量 | 上下文百分比%

- 颜色方案（ANSI）：
  - 路径：黄色加粗 \033[1;33m
  - git 分支（含 <>）：绿色加粗 \033[1;32m
  - 右侧所有信息：亮蓝色加粗 \033[1;36m

- 路径处理：$HOME 替换为 ~（直接用 ~ 字符，不要用 \~）
- git 分支：GIT_OPTIONAL_LOCKS=0 防阻塞，先 symbolic-ref 再 rev-parse，非 git 仓库不显示
- token 格式化：input + output 相加，< 1000 原始数字，>= 1000 显示 x.xk，>= 1000000 显示 x.xm
- 上下文百分比：取整后直接用 % 字符
- 用 printf "%b  %b\n" 输出

### 2. 配置 ~/.claude/settings.json

确保包含以下配置（与现有配置合并，不要覆盖已有内容）：

{
  "statusLine": {
    "type": "command",
    "command": "bash <绝对路径>/.claude/statusline-command.sh"
  }
}

command 中的路径用实际的 $HOME 绝对路径替换。
```
