# @atproto/mcp-server# atproto MCP Server



> Model Context Protocol (MCP) server for Bluesky/AT Protocol - Enable AI agents to interact with Bluesky seamlesslyThis directory contains the MCP (Model Context Protocol) server implementation for atproto, enabling AI agents to control Bluesky through standardized tool interfaces.



[![npm version](https://img.shields.io/npm/v/@atproto/mcp-server.svg)](https://www.npmjs.com/package/@atproto/mcp-server)## Overview

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

[![Node.js Version](https://img.shields.io/node/v/@atproto/mcp-server.svg)](https://nodejs.org)The MCP server acts as a bridge between AI agents (Claude, ChatGPT, etc.) and the atproto core library, exposing Bluesky/AT Protocol capabilities as discoverable MCP tools.



## What is this?## Architecture



This is a **Model Context Protocol (MCP) server** that gives AI agents like Claude, ChatGPT, and Copilot the ability to interact with Bluesky and the AT Protocol. It provides 34+ tools for authentication, posting, searching, following, and more.```

AI Agent

**Perfect for:**  ↓ (JSON-RPC 2.0 / stdio)

- 🤖 AI-powered social media automationMCP Server (this directory)

- 🛠️ Building Bluesky bots and agents  ↓ (calls functions)

- 🔗 Integrating Bluesky into AI workflowslib/atproto.sh (shared core)

- 📊 Intelligent content management systems  ↓ (XRPC requests)

- 🔬 Research and data collection from BlueskyBluesky/AT Protocol

```

## ✨ Features

## Directory Structure

- **34+ MCP Tools** covering all major Bluesky operations

- **Secure Authentication** with session management```

- **Rich Text Support** with hashtags, mentions, and URL detectionmcp-server/

- **Batch Operations** for efficient automation├── README.md                    # This file

- **Type-Safe** TypeScript implementation├── package.json                 # Node.js dependencies (if using Node)

- **Structured Logging** for debugging├── requirements.txt             # Python dependencies (if using Python)

- **Zero Configuration** - works out of the box├── Makefile                     # Build and development tasks

├── src/

## 🚀 Quick Start│   ├── index.js                 # MCP server entry point

│   ├── protocol/

### Installation│   │   └── mcp-protocol.js      # JSON-RPC 2.0 implementation

│   ├── tools/

```bash│   │   ├── auth-tools.js        # Authentication tool handlers

npm install -g @atproto/mcp-server│   │   ├── content-tools.js     # Post/content tool handlers

```│   │   ├── feed-tools.js        # Feed tool handlers

│   │   └── profile-tools.js     # Profile tool handlers

Or with the full atproto CLI:│   ├── lib/

│   │   ├── shell-executor.js    # Execute bash/shell commands

```bash│   │   ├── error-handler.js     # Error handling utilities

git clone https://github.com/p3nGu1nZz/atproto.git│   │   └── config-loader.js     # Configuration management

cd atproto│   └── types/

./install.sh│       └── index.d.ts           # TypeScript type definitions

```├── tests/

│   ├── unit/                    # Unit tests

### Usage with Claude Desktop│   ├── integration/             # Integration tests

│   └── fixtures/                # Test fixtures and mocks

Add to your Claude Desktop configuration (`~/Library/Application Support/Claude/claude_desktop_config.json` on macOS):└── docs/

    ├── DEVELOPMENT.md           # Development guide

```json    ├── DEPLOYMENT.md            # Deployment guide

{    └── TROUBLESHOOTING.md       # Troubleshooting guide

  "mcpServers": {```

    "atproto": {

      "command": "atproto-mcp-server"## Implementation Language

    }

  }**Recommended: Node.js/TypeScript**

}- ✅ Fast JSON-RPC 2.0 protocol handling

```- ✅ Strong typing for tool schemas

- ✅ Easy stdio communication

Restart Claude Desktop and you'll see atproto tools available!- ✅ Cross-platform support

- ✅ Active ecosystem

### Usage with VS Code Copilot

**Alternative: Python**

Add to your VS Code settings (`.vscode/settings.json`):- ✅ Rapid development

- ✅ Easy integration with AI services

```json- ✅ Rich data processing libraries

{

  "mcp.servers": {## Current Status

    "atproto": {

      "command": "atproto-mcp-server"**Phase 1 (Design):** ✅ Complete

    }- ✅ MCP protocol design documented

  }- ✅ Tool schemas defined (MCP_TOOLS.md)

}- ✅ Architecture designed (ARCHITECTURE.md)

```

**Phase 2 (Implementation):** ✅ In Progress

## 📚 Available Tools (34 total)- ✅ Set up development environment

- ✅ TypeScript/Node.js project structure

### Authentication (4)- ✅ Basic MCP server implementation

`auth_login`, `auth_logout`, `auth_whoami`, `auth_is_authenticated`- ✅ Authentication tools (4 tools)

- ✅ Content tools (post_create)

### Content (5)- ✅ Feed tools (feed_read)

`post_create`, `post_reply`, `post_like`, `post_repost`, `post_delete`- ⏳ Testing and refinement needed



### Feed (4)**Phase 3 (Integration):** ⏳ Pending

`feed_read`, `feed_search`, `feed_timeline`, `feed_notifications`- [ ] Package and distribute

- [ ] Publish to registries

### Profile (4)- [ ] Create integration guides

`profile_get`, `profile_follow`, `profile_unfollow`, `profile_block`

## Getting Started

### Social (6)

`follow_user`, `unfollow_user`, `block_user`, `unblock_user`, `get_followers`, `get_following`### Quick Start



### Search (3)```bash

`search_posts`, `search_users`, `search_timeline`# Install dependencies and build

npm install

### Batch Operations (5)npm run build

`batch_post`, `batch_follow`, `batch_unfollow`, `batch_like`, `batch_from_file`

# Test the server (it will wait for JSON-RPC input via stdin)

### Engagement (3)./atproto-mcp

`like_post`, `repost_post`, `delete_post`# Should output: atproto MCP Server started successfully

# Registered 29 tools

[📖 Full tool documentation →](https://github.com/p3nGu1nZz/atproto/blob/main/mcp-server/docs/MCP_TOOLS.md)# Press Ctrl+C to exit



## 💡 Examples# Test with a command

echo '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' | ./atproto-mcp

### Creating a Post```



**In Claude Desktop:**### Integration Guides

```

Can you post "Hello from AI! 🤖 #atprotocol" to my Bluesky account?- **Claude Desktop**: See [docs/CLAUDE_DESKTOP_SETUP.md](docs/CLAUDE_DESKTOP_SETUP.md)

```- **VS Code Copilot**: See [docs/VSCODE_COPILOT_SETUP.md](docs/VSCODE_COPILOT_SETUP.md)



Claude will use `post_create` and return the post URI.### Configuration



### Automated FollowingCopy and edit the example configuration:



**In Copilot:**```bash

```cp config.example.json config.json

Follow these users: alice.bsky.social, bob.bsky.social# Edit config.json with your absolute paths

``````



Copilot will use `batch_follow` to follow both users.### For Developers



### Search and AnalyzeSee [DEVELOPMENT.md](docs/DEVELOPMENT.md) for setup instructions.



```### For Users

Search for posts about "MCP" and summarize the top 5

```See [DEPLOYMENT.md](docs/DEPLOYMENT.md) for installation and usage.



AI uses `search_posts` then analyzes the results.## Quick Reference



## ⚙️ Configuration### Tool Categories



### Environment Variables**Authentication (4 tools)**

- `auth_login` - Authenticate user

- `ATP_PDS` - AT Protocol server (default: https://bsky.social)- `auth_logout` - Clear session

- `MCP_LOG_LEVEL` - Logging: DEBUG, INFO, WARN, ERROR (default: INFO)- `auth_whoami` - Get current user

- `MCP_LOG_CONSOLE` - Enable console logging (default: false)- `auth_is_authenticated` - Check auth status



### Authentication**Content (5 tools)**

- `post_create` - Create post

First, login via the atproto CLI:- `post_reply` - Reply to post

- `post_like` - Like post

```bash- `post_repost` - Repost content

atproto login- `post_delete` - Delete post

# Enter your handle and app password

```**Feed (4 tools)**

- `feed_read` - Read home feed

The session is stored securely and used by the MCP server automatically.- `feed_search` - Search posts

- `feed_timeline` - Get user timeline

## 🏗️ Architecture- `feed_notifications` - Get notifications



```**Profile (5 tools)**

AI Agent (Claude, ChatGPT, Copilot)- `profile_get` - Get profile

         ↓- `profile_follow` - Follow user

   JSON-RPC 2.0 / stdio- `profile_unfollow` - Unfollow user

         ↓- `profile_block` - Block user

   MCP Server (Node.js/TypeScript)- `profile_unblock` - Unblock user

         ↓

   Shell Executor → atproto CLIFor detailed schemas, see [MCP_TOOLS.md](../MCP_TOOLS.md)

         ↓

   AT Protocol / Bluesky API## Key Features

```

- ✅ Full MCP protocol compliance

## 🛠️ Development- ✅ Tool discovery and introspection

- ✅ Structured error handling

```bash- ✅ Session management

# Clone repository- ✅ Type-safe tool definitions

git clone https://github.com/p3nGu1nZz/atproto.git- ✅ Comprehensive logging

cd atproto/mcp-server- ✅ Rate limiting support

- ✅ Integration with lib/atproto.sh

# Install dependencies

npm install## Development



# Build### Install Dependencies

npm run build

```bash

# Run in development# Node.js

npm run devnpm install

```

# Python

## 🔒 Securitypip install -r requirements.txt

```

- ✅ **Never commit credentials** - Use app passwords

- ✅ **Session encryption** - AES-256-CBC encrypted### Run Tests

- ✅ **Secure by default** - All operations require authentication

- ✅ **Rate limiting** - Respects AT Protocol limits with exponential backoff```bash

npm test

## 🐛 Troubleshooting# or

make test

### MCP Server Not Showing in Claude```



1. Check config location: `~/Library/Application Support/Claude/`### Start Server (Development)

2. Verify `atproto-mcp-server` is in PATH: `which atproto-mcp-server`

3. Restart Claude Desktop completely```bash

4. Check logs: `~/Library/Logs/Claude/mcp*.log`npm run dev

# or

### Authentication Issuesmake dev

```

```bash

# Clear and re-login### Build for Production

atproto logout

atproto login```bash

```npm run build

# or

### Enable Debug Loggingmake build

```

```bash

export MCP_LOG_LEVEL=DEBUG## Configuration

export MCP_LOG_CONSOLE=true

atproto-mcp-serverThe MCP server reads configuration from:

```

1. Environment variables (highest priority)

## 🤝 Contributing2. `~/.config/atproto/mcp.json`

3. Default configuration

We welcome contributions! Areas we need help:

**Key Configuration Options:**

- 📚 More integration examples- `ATP_PDS` - AT Protocol server URL (default: https://bsky.social)

- 🧪 Additional test coverage- `MCP_LOG_LEVEL` - Logging level (debug, info, warn, error)

- 🌍 Internationalization- `MCP_TIMEOUT` - Request timeout in ms

- 📖 Documentation improvements- `MCP_PORT` - Port for stdio communication (usually managed by agent)



See [CONTRIBUTING.md](https://github.com/p3nGu1nZz/atproto/blob/main/CONTRIBUTING.md)## Debugging



## 🔗 Related Projects### Enable Debug Logging



- [atproto CLI](https://github.com/p3nGu1nZz/atproto) - Main CLI tool```bash

- [Model Context Protocol](https://modelcontextprotocol.io) - MCP specexport MCP_LOG_LEVEL=debug

- [Bluesky](https://bsky.app) - Bluesky social networknpm run dev

- [AT Protocol](https://atproto.com) - Underlying protocol```



## 📄 License### Check Server Health



MIT © atproto Contributors```bash

# Server responds to _meta/capabilities

## 💬 Support{

  "_meta": {

- [📖 Documentation](https://github.com/p3nGu1nZz/atproto)    "apiVersion": "2024-11-05",

- [💬 GitHub Discussions](https://github.com/p3nGu1nZz/atproto/discussions)    "name": "atproto-mcp-server",

- [🐛 Issue Tracker](https://github.com/p3nGu1nZz/atproto/issues)    "version": "0.1.0"

  },

---  "tools": [

    {...},

**Made with ❤️ for the AT Protocol and MCP communities**    {...}

  ]
}
```

## Security Considerations

1. **Credential Handling**
   - Credentials never logged
   - Session tokens stored with mode 600
   - Support for app passwords only

2. **Input Validation**
   - All inputs validated against schemas
   - Sanitization of user inputs
   - Rate limiting per agent

3. **Error Handling**
   - Sensitive information never exposed in errors
   - Consistent error response format
   - Proper HTTP status codes

See [SECURITY.md](../doc/SECURITY.md) for more details.

## Contributing

To contribute to the MCP server:

1. Follow [STYLE.md](../STYLE.md) conventions
2. Write tests for new tools
3. Update documentation
4. Submit pull request

See [CONTRIBUTING.md](../doc/CONTRIBUTING.md) for details.

## References

- [MCP Specification](https://modelcontextprotocol.io/)
- [MCP_TOOLS.md](../MCP_TOOLS.md) - Tool schemas
- [MCP_INTEGRATION.md](../MCP_INTEGRATION.md) - Integration guide
- [ARCHITECTURE.md](../ARCHITECTURE.md) - Technical design

## Support

For issues or questions:
- Check [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)
- Review [DEVELOPMENT.md](docs/DEVELOPMENT.md)
- Open an issue on GitHub
- See [doc/SECURITY.md](../doc/SECURITY.md) for security concerns

---

*Last updated: October 28, 2025*