# mcp 部署 Prompt

本目录暂无已配置的 MCP Server。添加后在此更新部署 prompt。

通用部署方式:

---

## Prompt

```
帮我配置 Claude Code 的 MCP Server。

在 ~/.claude/mcp.json 中添加以下 MCP Server 配置（如果文件不存在则创建，已存在则合并到 mcpServers 中，不覆盖已有配置）:

{
  "mcpServers": {
    "<server-name>": {
      "command": "<启动命令>",
      "args": ["<参数>"],
      "env": {}
    }
  }
}

路径中的 ~ 替换为实际的 $HOME 绝对路径。
```
