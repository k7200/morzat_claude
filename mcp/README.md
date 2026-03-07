# mcp — MCP Server 配置

本目录存放 Claude Code 的 MCP（Model Context Protocol）Server 配置，每个子目录对应一个 MCP Server。

## 当前状态

暂无已配置的 MCP Server。添加后按子目录管理，每个子目录包含配置文件、README.md 和 SETUP.md。

## MCP 配置说明

Claude Code 的 MCP 配置存放在以下位置:
- 用户级: `~/.claude/mcp.json`（所有项目生效）
- 项目级: `.mcp.json`（仅当前项目生效）

配置格式:
```json
{
  "mcpServers": {
    "server-name": {
      "command": "npx",
      "args": ["-y", "@some/mcp-server"],
      "env": {}
    }
  }
}
```

## 目录结构（示例）

```
mcp/
├── README.md
├── SETUP.md
├── filesystem/        # 某个 MCP Server
│   ├── README.md
│   ├── SETUP.md
│   └── config.json
└── ...
```
