# MCP Server Quick Start Guide

Get the atproto MCP server up and running in 5 minutes.

## What is MCP?

**MCP (Model Context Protocol)** is a standardized protocol that allows AI agents (like Claude, GitHub Copilot, ChatGPT) to use tools and access data through a unified interface. The atproto MCP server exposes all Bluesky/AT Protocol functionality as MCP tools.

## Prerequisites

- Node.js v18 or higher
- atproto installed (see main [README.md](../README.md))
- A Bluesky account with app password

## Step 1: Build the MCP Server

```bash
cd /path/to/atproto/mcp-server
npm install
npm run build
```

Expected output:
```
added 379 packages
```

## Step 2: Test the Server

```bash
# Test server startup
./atproto-mcp
```

You should see:
```
atproto MCP Server started successfully
Registered 29 tools
```

Press `Ctrl+C` to exit (the server waits for JSON-RPC input via stdin).

## Step 3: Test Tool Discovery

```bash
echo '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' | ./atproto-mcp | jq '.result.tools | length'
```

Should output: `29` (the number of registered tools)

## Step 4: Choose Your Integration

### Option A: Claude Desktop

1. **Locate config file** (create if doesn't exist):
   - macOS: `~/Library/Application Support/Claude/claude_desktop_config.json`
   - Windows: `%APPDATA%\Claude\claude_desktop_config.json`
   - Linux: `~/.config/claude/claude_desktop_config.json`

2. **Add atproto configuration**:
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

3. **Restart Claude Desktop**

4. **Verify**: In Claude, ask "Can you list the available atproto tools?"

📚 **Full Guide**: [mcp-server/docs/CLAUDE_DESKTOP_SETUP.md](../mcp-server/docs/CLAUDE_DESKTOP_SETUP.md)

### Option B: VS Code Copilot

1. **Open VS Code settings JSON**:
   - Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on macOS)
   - Type "Preferences: Open User Settings (JSON)"

2. **Add configuration**:
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

3. **Reload window**: `Ctrl+Shift+P` → "Developer: Reload Window"

4. **Verify**: In Copilot Chat, type "@atproto list tools"

📚 **Full Guide**: [mcp-server/docs/VSCODE_COPILOT_SETUP.md](../mcp-server/docs/VSCODE_COPILOT_SETUP.md)

## Step 5: Login to Bluesky

### Via Claude Desktop

```
Please login to Bluesky:
- Handle: myhandle.bsky.social
- Password: [my app password]
```

### Via VS Code Copilot

```
@atproto Login with handle: myhandle.bsky.social and password: [app password]
```

### Via CLI (alternative)

```bash
# Login using the CLI
atproto login

# Verify session
atproto whoami
```

The MCP server will use the same session file as the CLI (`~/.config/atproto/session.json`).

## Step 6: Try It Out!

### Create a Post

**Claude Desktop:**
```
Create a Bluesky post: "Testing the atproto MCP server! 🚀 #opensource"
```

**VS Code Copilot:**
```
@atproto Create a post saying: "Hello from VS Code! 👋"
```

### Read Your Feed

**Claude Desktop:**
```
Show me the latest 5 posts from my Bluesky feed
```

**VS Code Copilot:**
```
@atproto Read my feed (5 posts)
```

### Search for Posts

**Claude Desktop:**
```
Search Bluesky for posts about "AI agents"
```

**VS Code Copilot:**
```
@atproto Search for posts about "TypeScript"
```

## Available Tools (29 total)

### Authentication (4)
- `auth_login` - Login with credentials
- `auth_logout` - Logout
- `auth_whoami` - Get current user
- `auth_is_authenticated` - Check auth status

### Content (5)
- `post_create` - Create post
- `post_with_image` - Post with image
- `post_with_gallery` - Post with multiple images
- `post_with_video` - Post with video
- `post_reply` - Reply to post

### Engagement (5)
- `post_like` - Like a post
- `post_repost` - Repost
- `post_delete` - Delete post
- `upload_media` - Upload media files

### Feed & Search (4)
- `feed_read` - Read timeline
- `read_feed` - Read with options
- `search_posts` - Search posts
- `search_users` - Search users

### Profile (4)
- `profile_get` - Get profile
- `profile_edit` - Edit profile
- `profile_get_followers` - List followers
- `profile_get_following` - List following

### Social (7)
- `follow_user` / `user_follow` - Follow
- `unfollow_user` / `user_unfollow` - Unfollow
- `get_followers` - Follower list
- `get_following` - Following list
- `block_user` - Block user
- `unblock_user` - Unblock user

## Troubleshooting

### Server Won't Start

```bash
# Check Node.js version
node --version  # Should be v18+

# Rebuild
cd mcp-server
rm -rf node_modules dist
npm install
npm run build
```

### Tools Not Appearing

1. **Check path**: Use absolute path in config
2. **Check JSON**: Validate config syntax
3. **Restart**: Fully restart Claude/VS Code
4. **Check logs**: Look for errors in application logs

### Authentication Fails

1. **Use app password**: Never use main account password
   - Go to Bluesky Settings → App Passwords → Create
2. **Check handle format**: Use full handle like `user.bsky.social`
3. **Verify PDS**: Default is `https://bsky.social`

### Command Hangs

The MCP server uses **stdio communication** - it's designed to wait for JSON-RPC input. This is normal behavior! The server should be started by the AI agent (Claude/Copilot), not manually.

If you want to test manually:
```bash
# Use timeout
timeout 2 ./atproto-mcp

# Or send a command
echo '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' | ./atproto-mcp
```

## Security Notes

- ✅ **Use app passwords** - Create in Bluesky settings, never share main password
- ✅ **Local only** - MCP server runs locally, no network exposure
- ✅ **Encrypted storage** - Session tokens stored encrypted (AES-256-CBC)
- ✅ **Permissions** - Server has same permissions as authenticated user

## Next Steps

- 📚 Read [CLAUDE_DESKTOP_SETUP.md](../mcp-server/docs/CLAUDE_DESKTOP_SETUP.md) for advanced Claude integration
- 📚 Read [VSCODE_COPILOT_SETUP.md](../mcp-server/docs/VSCODE_COPILOT_SETUP.md) for VS Code workflows
- 🤖 Explore [AGENTS.md](../AGENTS.md) for automation patterns
- 🔧 Check [MCP_INTEGRATION.md](MCP_INTEGRATION.md) for technical details
- 💡 Browse examples in [examples/](../examples/)

## Getting Help

- 📖 Documentation: [README.md](../README.md)
- 🐛 Issues: [GitHub Issues](https://github.com/p3nGu1nZz/atproto/issues)
- 💬 Discussions: GitHub Discussions
- 🔒 Security: [SECURITY.md](SECURITY.md)

## Success!

You now have the atproto MCP server running and integrated with your AI assistant! 🎉

Try asking your AI assistant to:
- Create posts on Bluesky
- Read and search your feed
- Follow users and manage your social graph
- Upload images and create rich posts
- Automate your Bluesky workflows

Happy automating! 🚀

---

*Last updated: October 31, 2025*
