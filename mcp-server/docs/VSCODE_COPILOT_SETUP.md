# VS Code Copilot MCP Setup Guide

This guide shows how to integrate the atproto MCP server with VS Code GitHub Copilot.

## Prerequisites

- VS Code with GitHub Copilot extension
- Node.js v18+ installed
- atproto MCP server built (`npm install` completed)

## Configuration Steps

### 1. Locate VS Code Settings

Open VS Code settings in JSON format:
- Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on macOS)
- Type "Preferences: Open User Settings (JSON)"
- Press Enter

### 2. Add MCP Server Configuration

Add the following to your `settings.json`:

```json
{
  "github.copilot.chat.mcp.servers": {
    "atproto": {
      "command": "node",
      "args": [
        "/absolute/path/to/atproto/mcp-server/dist/index.js"
      ],
      "env": {
        "ATP_PDS": "https://bsky.social"
      }
    }
  }
}
```

**Important**: Replace `/absolute/path/to/atproto` with your actual installation path.

**Example paths**:
- macOS/Linux: `/home/username/projects/atproto/mcp-server/dist/index.js`
- Windows: `C:\\Users\\username\\projects\\atproto\\mcp-server\\dist\\index.js`
- WSL: `/mnt/c/Users/username/source/repos/atproto/mcp-server/dist/index.js`

### 3. Reload VS Code

- Press `Ctrl+Shift+P` (or `Cmd+Shift+P`)
- Type "Developer: Reload Window"
- Press Enter

### 4. Verify Integration

Open the GitHub Copilot Chat panel and ask:

```
@atproto Can you list available tools?
```

You should see the 29 atproto tools available for use.

## Using atproto with Copilot

### Mentioning the MCP Server

Use `@atproto` to invoke the MCP server in Copilot Chat:

```
@atproto login to Bluesky with handle user.bsky.social
```

### Example Workflows

**1. Post from your editor:**
```
@atproto Create a post: "Just finished implementing a new feature! 🎉"
```

**2. Read your feed:**
```
@atproto Show me the latest 5 posts from my Bluesky feed
```

**3. Search for content:**
```
@atproto Search for posts about "TypeScript MCP"
```

**4. Follow a user:**
```
@atproto Follow @bsky.app
```

**5. Get profile information:**
```
@atproto Get profile for @user.bsky.social
```

## Available Tools

The atproto MCP server provides 29 tools across these categories:

### Authentication (4 tools)
- `auth_login` - Login with credentials
- `auth_logout` - Logout and clear session
- `auth_whoami` - Get current user info
- `auth_is_authenticated` - Check authentication status

### Content Creation (5 tools)
- `post_create` - Create a text post
- `post_with_image` - Post with single image
- `post_with_gallery` - Post with multiple images (up to 4)
- `post_with_video` - Post with video
- `post_reply` - Reply to a post

### Feed & Search (4 tools)
- `feed_read` - Read your timeline
- `read_feed` - Read feed with custom limit
- `search_posts` - Search for posts by query
- `search_users` - Search for users

### Profile Management (4 tools)
- `profile_get` - Get user profile
- `profile_edit` - Edit your profile (name, bio, avatar, banner)
- `profile_get_followers` - List followers
- `profile_get_following` - List following

### Engagement (5 tools)
- `post_like` - Like a post
- `post_repost` - Repost content
- `post_delete` - Delete your post
- `upload_media` - Upload images/videos

### Social Actions (7 tools)
- `follow_user` / `user_follow` - Follow users
- `unfollow_user` / `user_unfollow` - Unfollow users
- `get_followers` - Get follower list
- `get_following` - Get following list
- `block_user` - Block a user
- `unblock_user` - Unblock a user

## Workspace-Specific Configuration

For workspace-specific settings, create `.vscode/settings.json` in your project:

```json
{
  "github.copilot.chat.mcp.servers": {
    "atproto": {
      "command": "node",
      "args": [
        "${workspaceFolder}/mcp-server/dist/index.js"
      ],
      "env": {
        "ATP_PDS": "https://bsky.social"
      }
    }
  }
}
```

This uses the MCP server from your current workspace.

## Development Workflows

### 1. Post Release Notes

```
@atproto After we tag v1.0.0, create a post announcing:
"🎉 atproto v1.0.0 is now available! Check it out at github.com/p3nGu1nZz/atproto
#opensource #bluesky"
```

### 2. Share Code Snippets

```
@atproto Post this code snippet with explanation:
"New feature: MCP server integration! Now you can use atproto directly from AI assistants.
[code snippet]"
```

### 3. Automated Testing Posts

```
@atproto After successful CI/CD run, post:
"✅ All tests passing on main branch. Coverage: 95%"
```

### 4. Community Engagement

```
@atproto Search for recent posts mentioning "atproto" to see what the community is saying
```

## Troubleshooting

### Server Not Starting

1. **Verify Node.js version**:
   ```bash
   node --version  # Should be v18 or higher
   ```

2. **Build the server**:
   ```bash
   cd /path/to/atproto/mcp-server
   npm install
   npm run build
   ```

3. **Test manually**:
   ```bash
   node dist/index.js
   # Should output: atproto MCP Server started successfully
   ```

### Tools Not Available

1. **Check settings.json syntax** - Ensure valid JSON
2. **Verify path** - Use absolute path to `dist/index.js`
3. **Reload window** - Use "Developer: Reload Window" command
4. **Check Copilot logs** - Open "Output" panel, select "GitHub Copilot Chat"

### Authentication Issues

1. **Use app passwords** - Create in Bluesky settings
2. **Check handle format** - Use full format: `user.bsky.social`
3. **Verify session** - Check `~/.config/atproto/session.json` exists

### Permission Errors

On Linux/macOS, ensure execute permissions:
```bash
chmod +x /path/to/atproto/mcp-server/dist/index.js
```

## Security Considerations

- **App Passwords**: Always use app passwords, not your main password
- **Local Execution**: MCP server runs locally via stdio (no network exposure)
- **Encrypted Storage**: Sessions stored encrypted in `~/.config/atproto/session.json`
- **Permissions**: Server has same permissions as authenticated user
- **Code Review**: Review automation scripts before posting

## Advanced Configuration

### Custom PDS Server

```json
{
  "github.copilot.chat.mcp.servers": {
    "atproto": {
      "command": "node",
      "args": ["/path/to/atproto/mcp-server/dist/index.js"],
      "env": {
        "ATP_PDS": "https://your-custom-pds.example.com"
      }
    }
  }
}
```

### Debug Mode

Enable debug logging:

```json
{
  "github.copilot.chat.mcp.servers": {
    "atproto": {
      "command": "node",
      "args": ["/path/to/atproto/mcp-server/dist/index.js"],
      "env": {
        "ATP_PDS": "https://bsky.social",
        "DEBUG": "1"
      }
    }
  }
}
```

### Multiple Accounts

Configure multiple MCP servers for different Bluesky accounts:

```json
{
  "github.copilot.chat.mcp.servers": {
    "atproto-personal": {
      "command": "node",
      "args": ["/path/to/atproto/mcp-server/dist/index.js"],
      "env": {
        "CONFIG_DIR": "/home/user/.config/atproto-personal"
      }
    },
    "atproto-bot": {
      "command": "node",
      "args": ["/path/to/atproto/mcp-server/dist/index.js"],
      "env": {
        "CONFIG_DIR": "/home/user/.config/atproto-bot"
      }
    }
  }
}
```

## Integration Examples

### GitHub Actions Integration

```yaml
name: Post Release
on:
  release:
    types: [published]
jobs:
  announce:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Post to Bluesky
        run: |
          npm install -g atproto-mcp-server
          echo '{"jsonrpc":"2.0","method":"tools/call","params":{"name":"post_create","arguments":{"text":"🎉 New release: ${{ github.event.release.tag_name }}"}}}' | atproto-mcp-server
```

### Automated Documentation Updates

```
@atproto After updating README.md, create a post:
"📚 Documentation updated! Check out the new features guide."
```

## Tips & Best Practices

1. **Use app passwords** - More secure than main password
2. **Test locally first** - Verify posts before automation
3. **Rate limiting** - Be mindful of API rate limits
4. **Error handling** - Check responses before proceeding
5. **Human oversight** - Review automated posts before publishing

## Resources

- [MCP Protocol Documentation](https://modelcontextprotocol.io/)
- [AT Protocol Docs](https://atproto.com/)
- [Bluesky API Reference](https://docs.bsky.app/)
- [GitHub Copilot MCP Guide](https://code.visualstudio.com/docs/copilot/copilot-mcp)
- [atproto GitHub](https://github.com/p3nGu1nZz/atproto)

## Support

For issues or questions:
- GitHub Issues: https://github.com/p3nGu1nZz/atproto/issues
- Documentation: Project README and docs
- Community: Bluesky @atproto.bsky.social

---

*Last updated: October 31, 2025*
