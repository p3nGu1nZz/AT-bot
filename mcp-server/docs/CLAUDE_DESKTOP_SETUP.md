# Claude Desktop MCP Setup Guide

This guide shows how to integrate the atproto MCP server with Claude Desktop.

## Prerequisites

- Node.js v18+ installed
- atproto MCP server built (`npm install` completed)
- Claude Desktop application

## Configuration Steps

### 1. Locate Claude Desktop Configuration

The configuration file location depends on your operating system:

- **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Windows**: `%APPDATA%\Claude\claude_desktop_config.json`
- **Linux**: `~/.config/claude/claude_desktop_config.json`

### 2. Add atproto MCP Server

Edit the configuration file and add the atproto server:

```json
{
  "mcpServers": {
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

**Important**: Replace `/absolute/path/to/atproto` with the actual path to your atproto installation.

**Example paths**:
- macOS/Linux: `/home/username/projects/atproto/mcp-server/dist/index.js`
- Windows: `C:\\Users\\username\\projects\\atproto\\mcp-server\\dist\\index.js`
- WSL: `/mnt/c/Users/username/source/repos/atproto/mcp-server/dist/index.js`

### 3. Restart Claude Desktop

Close and restart Claude Desktop to load the new MCP server configuration.

### 4. Verify Integration

In a new Claude conversation, you should see the atproto tools available. You can verify by asking:

```
Can you list the available atproto tools?
```

Claude should respond with the 29 available tools for Bluesky/AT Protocol operations.

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
- `post_with_gallery` - Post with multiple images
- `post_with_video` - Post with video
- `post_reply` - Reply to a post

### Feed & Timeline (4 tools)
- `feed_read` - Read your timeline
- `read_feed` - Read feed with options
- `search_posts` - Search for posts
- `search_users` - Search for users

### Profile Management (4 tools)
- `profile_get` - Get profile information
- `profile_edit` - Edit your profile
- `profile_get_followers` - List followers
- `profile_get_following` - List following

### Engagement (5 tools)
- `post_like` - Like a post
- `post_repost` - Repost content
- `post_delete` - Delete a post
- `upload_media` - Upload media files

### Social Actions (6 tools)
- `follow_user` / `user_follow` - Follow users
- `unfollow_user` / `user_unfollow` - Unfollow users
- `get_followers` - Get follower list
- `get_following` - Get following list
- `block_user` - Block a user
- `unblock_user` - Unblock a user

## Usage Examples

### Login to Bluesky

```
Please login to Bluesky with:
- Handle: myhandle.bsky.social
- Password: [your app password]
```

### Create a Post

```
Create a post saying: "Hello from Claude Desktop using the atproto MCP server! 🚀"
```

### Read Your Feed

```
Show me the latest 10 posts from my Bluesky feed
```

### Search for Posts

```
Search for posts about "AI agents"
```

### Follow a User

```
Follow the user @bsky.app
```

## Troubleshooting

### Server Not Starting

1. **Check Node.js version**: Ensure you have Node.js v18 or higher
   ```bash
   node --version
   ```

2. **Verify build**: Make sure the server is built
   ```bash
   cd /path/to/atproto/mcp-server
   npm install
   npm run build
   ```

3. **Test manually**: Run the server directly to check for errors
   ```bash
   node dist/index.js
   ```

### Tools Not Appearing

1. **Check configuration path**: Ensure the path in `claude_desktop_config.json` is absolute and correct
2. **Check JSON syntax**: Validate the JSON configuration file
3. **Restart Claude**: Fully quit and restart Claude Desktop
4. **Check logs**: Look for errors in Claude Desktop logs

### Authentication Issues

1. **Use app passwords**: Create an app password in Bluesky settings (don't use your main password)
2. **Check handle format**: Use full handle like `user.bsky.social`
3. **Verify PDS endpoint**: Default is `https://bsky.social`

## Security Notes

- **App Passwords**: Always use app passwords, never your main account password
- **Credentials**: The atproto CLI stores encrypted session tokens in `~/.config/atproto/session.json`
- **Permissions**: The MCP server has the same permissions as the authenticated user
- **Local Only**: The MCP server runs locally and communicates via stdio (no network exposure)

## Advanced Configuration

### Custom PDS Server

To use a custom AT Protocol PDS server:

```json
{
  "mcpServers": {
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

### Multiple Accounts

You can configure multiple atproto servers for different accounts:

```json
{
  "mcpServers": {
    "atproto-personal": {
      "command": "node",
      "args": ["/path/to/atproto/mcp-server/dist/index.js"],
      "env": {
        "ATP_PDS": "https://bsky.social",
        "CONFIG_DIR": "/home/user/.config/atproto-personal"
      }
    },
    "atproto-work": {
      "command": "node",
      "args": ["/path/to/atproto/mcp-server/dist/index.js"],
      "env": {
        "ATP_PDS": "https://bsky.social",
        "CONFIG_DIR": "/home/user/.config/atproto-work"
      }
    }
  }
}
```

## Support

For issues or questions:
- GitHub Issues: https://github.com/p3nGu1nZz/atproto/issues
- Documentation: https://github.com/p3nGu1nZz/atproto/blob/main/README.md
- MCP Protocol: https://modelcontextprotocol.io/

## Next Steps

- Explore automation workflows with Claude
- Create custom agent scripts
- Integrate with other MCP servers
- Contribute to the project

---

*Last updated: October 31, 2025*
