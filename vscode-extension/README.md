# atproto VS Code Extension

AT Protocol/Bluesky integration for VS Code with native MCP server support.

## Features

- **Zero Configuration**: Automatic MCP server setup for AI agents
- **Native Authentication**: Secure Bluesky login with VS Code SecretStorage
- **29 AT Protocol Tools**: Complete access to posting, feeds, profiles, and social features
- **Command Integration**: Rich command palette and status bar integration
- **AI Agent Ready**: Works seamlessly with GitHub Copilot and other MCP-compatible tools

## Quick Start

1. Install the extension from the VS Code marketplace
2. Click the `@` icon in the status bar to login to Bluesky
3. Enter your handle and app password (recommended)
4. Start using `@atproto` in Copilot chat for AT Protocol operations

## Available Commands

- `atproto: Login to Bluesky` - Authenticate with your Bluesky account
- `atproto: Logout` - Clear stored credentials
- `atproto: Create Post` - Quick post creation
- `atproto: Install CLI Tool` - Install standalone CLI (coming soon)

## MCP Tools

The extension provides 29 tools for AI agents:

### Authentication (4 tools)
- `auth_login`, `auth_logout`, `auth_whoami`, `auth_is_authenticated`

### Content Management (5 tools)  
- `post_create`, `post_reply`, `post_like`, `post_repost`, `post_delete`

### Feed Operations (4 tools)
- `feed_read`, `feed_search`, `feed_timeline`, `feed_notifications`

### Profile Management (4 tools)
- `profile_get`, `profile_follow`, `profile_unfollow`, `profile_block`

### Search & Discovery (3 tools)
- `search_posts`, `search_users`, `search_feeds`

### Social Features (6 tools)
- `follow_user`, `unfollow_user`, `block_user`, `unblock_user`, `get_followers`, `get_following`

### Engagement (3 tools)
- `like_post`, `unlike_post`, `repost_content`

## Configuration

| Setting | Default | Description |
|---------|---------|-------------|
| `atproto.pdsEndpoint` | `https://bsky.social` | AT Protocol server endpoint |
| `atproto.autoLogin` | `true` | Automatically login on extension activation |
| `atproto.debugMode` | `false` | Enable debug logging |

## Security

- Credentials are stored securely using VS Code's SecretStorage API
- App passwords are recommended over main account passwords
- No telemetry or data collection
- All communication is encrypted

## Development

### Building from Source

```bash
cd vscode-extension
npm install
npm run compile
```

### Packaging

```bash
npm run package
```

### Testing

```bash
npm test
```

## Support

- **Issues**: [GitHub Issues](https://github.com/p3nGu1nZz/atproto/issues)
- **Documentation**: [Project Docs](https://github.com/p3nGu1nZz/atproto)

## License

MIT - see [LICENSE](../LICENSE) for details.