# VS Code Extension for atproto

## Overview

The atproto VS Code extension provides seamless AT Protocol/Bluesky integration through a native MCP (Model Context Protocol) server implementation. This extension eliminates the need for manual configuration and provides AI agents like GitHub Copilot direct access to Bluesky functionality.

## Key Features

- **Zero Configuration**: Automatic setup without manual dependency installation
- **Native MCP Integration**: Built-in MCP server using VS Code's `McpServerDefinitionProvider` API
- **Secure Authentication**: Integrated Bluesky login with VS Code SecretStorage API
- **Command Integration**: Rich command palette and status bar integration
- **29 AT Protocol Tools**: Complete access to posting, feeds, profiles, and social features

## Architecture

The extension follows a three-layer architecture:

1. **Extension Host (TypeScript)**: VS Code extension with MCP provider, lifecycle management, and UI
2. **Bundled MCP Server**: Pre-compiled MCP server providing 29 AT Protocol tools
3. **Optional CLI Tools**: Install script for standalone `atproto` command usage

## Installation

### From VS Code Marketplace (Recommended)
1. Open VS Code
2. Go to Extensions (Ctrl+Shift+X)
3. Search for "atproto"
4. Click "Install"
5. Extension auto-configures itself

### Manual Installation (Development)
```bash
# Clone repository
git clone https://github.com/p3nGu1nZz/atproto.git
cd atproto

# Build extension
cd vscode-extension
npm install
npm run compile
vsce package

# Install locally
code --install-extension atproto-0.1.0.vsix
```

## Usage

### First-Time Setup
1. Install extension from marketplace
2. Extension activates automatically on VS Code startup
3. When using atproto in Copilot chat:
   - Extension prompts for Bluesky login
   - Enter handle + app password in secure webview
   - Credentials stored using VS Code SecretStorage
   - MCP server starts automatically

### Available Commands

**Command Palette** (`Ctrl+Shift+P`):
- `atproto: Login to Bluesky` - Authenticate with Bluesky
- `atproto: Logout` - Clear session and credentials
- `atproto: Create Post` - Quick post creation
- `atproto: Install CLI Tool` - Install standalone CLI

**Status Bar**: Shows authentication status and quick access to login

### MCP Tools Available

The extension provides 29 tools organized by category:

**Authentication** (4 tools):
- `auth_login`, `auth_logout`, `auth_whoami`, `auth_is_authenticated`

**Content Management** (5 tools):
- `post_create`, `post_reply`, `post_like`, `post_repost`, `post_delete`

**Feed Operations** (4 tools):
- `feed_read`, `feed_search`, `feed_timeline`, `feed_notifications`

**Profile Management** (4 tools):
- `profile_get`, `profile_follow`, `profile_unfollow`, `profile_block`

**Search & Discovery** (3 tools):
- `search_posts`, `search_users`, `search_feeds`

**Social Features** (6 tools):
- `follow_user`, `unfollow_user`, `block_user`, `unblock_user`, `get_followers`, `get_following`

**Engagement** (3 tools):
- `like_post`, `unlike_post`, `repost_content`

## Configuration

The extension supports these configuration options:

```json
{
  "atproto.pdsEndpoint": "https://bsky.social",
  "atproto.autoLogin": true,
  "atproto.debugMode": false
}
```

## Security

- **Credential Storage**: Uses VS Code SecretStorage API for secure credential management
- **No Data Collection**: Extension doesn't collect telemetry or user data
- **App Passwords**: Supports Bluesky app passwords for enhanced security
- **Session Management**: Automatic session refresh and secure token storage

## Development

### Building from Source
```bash
# Prerequisites
node --version  # 18.0.0 or higher
npm install -g @vscode/vsce

# Build extension
cd vscode-extension
npm install
npm run compile
```

### Testing
```bash
# Run tests
npm test

# Debug extension
# Press F5 in VS Code to launch Extension Development Host
```

## Troubleshooting

### Common Issues

**Extension not appearing in Copilot**:
1. Check VS Code version (requires 1.96.0+)
2. Verify `github.copilot.chat.mcp.enabled` is true
3. Reload VS Code window

**Authentication failures**:
1. Use app passwords instead of main password
2. Check PDS endpoint configuration
3. Clear credentials and re-authenticate

**MCP server not starting**:
1. Check VS Code output panel for errors
2. Verify Node.js installation (if using bundled server)
3. Restart VS Code

### Debug Mode

Enable debug logging:
```json
{
  "atproto.debugMode": true
}
```

Check VS Code Output panel → "atproto" for debug information.

## Related Documentation

- **[VSCODE_EXTENSION_PLAN.md](../VSCODE_EXTENSION_PLAN.md)**: Strategic planning and implementation roadmap
- **[VSCODE_EXTENSION_DEVELOPMENT.md](../VSCODE_EXTENSION_DEVELOPMENT.md)**: Technical development guidelines and best practices
- **[MCP_TOOLS.md](../mcp-server/docs/MCP_TOOLS.md)**: Complete MCP tool reference
- **[QUICKSTART_MCP.md](../mcp-server/docs/QUICKSTART_MCP.md)**: MCP server setup guide

## Support

- **Issues**: [GitHub Issues](https://github.com/p3nGu1nZz/atproto/issues)
- **Documentation**: [Project Documentation](https://github.com/p3nGu1nZz/atproto)
- **Community**: [Bluesky @atproto.dev](https://bsky.app/profile/atproto.dev)

## License

MIT License - see [LICENSE](../LICENSE) for details.

---

*Last updated: October 31, 2025*