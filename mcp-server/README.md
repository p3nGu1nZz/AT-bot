# AT-bot MCP Server

This directory contains the MCP (Model Context Protocol) server implementation for AT-bot, enabling AI agents to control Bluesky through standardized tool interfaces.

## Overview

The MCP server acts as a bridge between AI agents (Claude, ChatGPT, etc.) and the AT-bot core library, exposing Bluesky/AT Protocol capabilities as discoverable MCP tools.

## Architecture

```
AI Agent
  ↓ (JSON-RPC 2.0 / stdio)
MCP Server (this directory)
  ↓ (calls functions)
lib/atproto.sh (shared core)
  ↓ (XRPC requests)
Bluesky/AT Protocol
```

## Directory Structure

```
mcp-server/
├── README.md                    # This file
├── package.json                 # Node.js dependencies (if using Node)
├── requirements.txt             # Python dependencies (if using Python)
├── Makefile                     # Build and development tasks
├── src/
│   ├── index.js                 # MCP server entry point
│   ├── protocol/
│   │   └── mcp-protocol.js      # JSON-RPC 2.0 implementation
│   ├── tools/
│   │   ├── auth-tools.js        # Authentication tool handlers
│   │   ├── content-tools.js     # Post/content tool handlers
│   │   ├── feed-tools.js        # Feed tool handlers
│   │   └── profile-tools.js     # Profile tool handlers
│   ├── lib/
│   │   ├── shell-executor.js    # Execute bash/shell commands
│   │   ├── error-handler.js     # Error handling utilities
│   │   └── config-loader.js     # Configuration management
│   └── types/
│       └── index.d.ts           # TypeScript type definitions
├── tests/
│   ├── unit/                    # Unit tests
│   ├── integration/             # Integration tests
│   └── fixtures/                # Test fixtures and mocks
└── docs/
    ├── DEVELOPMENT.md           # Development guide
    ├── DEPLOYMENT.md            # Deployment guide
    └── TROUBLESHOOTING.md       # Troubleshooting guide
```

## Implementation Language

**Recommended: Node.js/TypeScript**
- ✅ Fast JSON-RPC 2.0 protocol handling
- ✅ Strong typing for tool schemas
- ✅ Easy stdio communication
- ✅ Cross-platform support
- ✅ Active ecosystem

**Alternative: Python**
- ✅ Rapid development
- ✅ Easy integration with AI services
- ✅ Rich data processing libraries

## Current Status

**Phase 1 (Design):** ✅ Complete
- ✅ MCP protocol design documented
- ✅ Tool schemas defined (MCP_TOOLS.md)
- ✅ Architecture designed (ARCHITECTURE.md)

**Phase 2 (Implementation):** ⏳ In Progress
- [ ] Set up development environment
- [ ] Implement MCP protocol handler
- [ ] Implement tool handlers
- [ ] Write tests
- [ ] Create documentation

**Phase 3 (Integration):** ⏳ Pending
- [ ] Package and distribute
- [ ] Publish to registries
- [ ] Create integration guides

## Getting Started

### For Developers

See [DEVELOPMENT.md](docs/DEVELOPMENT.md) for setup instructions.

### For Users

See [DEPLOYMENT.md](docs/DEPLOYMENT.md) for installation and usage.

## Quick Reference

### Tool Categories

**Authentication (4 tools)**
- `auth_login` - Authenticate user
- `auth_logout` - Clear session
- `auth_whoami` - Get current user
- `auth_is_authenticated` - Check auth status

**Content (5 tools)**
- `post_create` - Create post
- `post_reply` - Reply to post
- `post_like` - Like post
- `post_repost` - Repost content
- `post_delete` - Delete post

**Feed (4 tools)**
- `feed_read` - Read home feed
- `feed_search` - Search posts
- `feed_timeline` - Get user timeline
- `feed_notifications` - Get notifications

**Profile (5 tools)**
- `profile_get` - Get profile
- `profile_follow` - Follow user
- `profile_unfollow` - Unfollow user
- `profile_block` - Block user
- `profile_unblock` - Unblock user

For detailed schemas, see [MCP_TOOLS.md](../MCP_TOOLS.md)

## Key Features

- ✅ Full MCP protocol compliance
- ✅ Tool discovery and introspection
- ✅ Structured error handling
- ✅ Session management
- ✅ Type-safe tool definitions
- ✅ Comprehensive logging
- ✅ Rate limiting support
- ✅ Integration with lib/atproto.sh

## Development

### Install Dependencies

```bash
# Node.js
npm install

# Python
pip install -r requirements.txt
```

### Run Tests

```bash
npm test
# or
make test
```

### Start Server (Development)

```bash
npm run dev
# or
make dev
```

### Build for Production

```bash
npm run build
# or
make build
```

## Configuration

The MCP server reads configuration from:

1. Environment variables (highest priority)
2. `~/.config/at-bot/mcp.json`
3. Default configuration

**Key Configuration Options:**
- `ATP_PDS` - AT Protocol server URL (default: https://bsky.social)
- `MCP_LOG_LEVEL` - Logging level (debug, info, warn, error)
- `MCP_TIMEOUT` - Request timeout in ms
- `MCP_PORT` - Port for stdio communication (usually managed by agent)

## Debugging

### Enable Debug Logging

```bash
export MCP_LOG_LEVEL=debug
npm run dev
```

### Check Server Health

```bash
# Server responds to _meta/capabilities
{
  "_meta": {
    "apiVersion": "2024-11-05",
    "name": "at-bot-mcp-server",
    "version": "0.1.0"
  },
  "tools": [
    {...},
    {...}
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