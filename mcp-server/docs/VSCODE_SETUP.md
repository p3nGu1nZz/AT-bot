# VS Code Setup Guide for atproto MCP Server

This guide walks you through setting up the atproto MCP server with GitHub Copilot in VS Code.

## Prerequisites

- VS Code 1.96.0 or later
- GitHub Copilot extension installed and activated
- atproto CLI and MCP server installed (`sudo ./install.sh --mcp`)

## Step 1: Install the VS Code Extension

### Option A: Install from VSIX (Recommended for testing)

1. Open VS Code
2. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
3. Type: `Extensions: Install from VSIX...`
4. Navigate to your atproto project directory
5. Select `atproto-0.1.0.vsix`
6. Click "Install"
7. Reload VS Code when prompted

### Option B: Install from Marketplace (Coming Soon)

Once published, you can install directly from the VS Code Marketplace:
- Search for "atproto" in the Extensions view
- Click "Install"

## Step 2: Verify Installation

1. Check that atproto CLI is accessible:
   ```bash
   which atproto
   # Should output: /usr/local/bin/atproto
   ```

2. Test MCP server:
   ```bash
   atproto mcp-server --help
   ```

## Step 3: Configure MCP Server

### For GitHub Copilot

The atproto VS Code extension automatically configures itself with Copilot. However, you can manually verify or adjust the configuration:

1. Open VS Code settings (JSON):
   - Press `Ctrl+Shift+P` → `Preferences: Open User Settings (JSON)`
   
2. Add or verify this configuration:
   ```json
   {
     "github.copilot.chat.mcp.enabled": true,
     "github.copilot.chat.mcp.servers": {
       "atproto": {
         "command": "/usr/local/bin/atproto",
         "args": ["mcp-server"],
         "env": {
           "ATP_PDS": "https://bsky.social"
         }
       }
     }
   }
   ```

3. Save and reload VS Code:
   - Press `Ctrl+Shift+P` → `Developer: Reload Window`

## Step 4: Authenticate with Bluesky

You have two options for authentication:

### Option A: Use CLI to Login First (Recommended)

```bash
atproto login
# Enter your Bluesky handle and app password
```

The MCP server will use your existing session automatically.

### Option B: Use VS Code Commands

1. Open Command Palette: `Ctrl+Shift+P`
2. Type: `atproto: Login to Bluesky`
3. Enter your handle and app password

## Step 5: Test the Integration

### Test with GitHub Copilot Chat

1. Open Copilot Chat: `Ctrl+Alt+I` (or click the chat icon)

2. Try these test commands:

   **Check Authentication:**
   ```
   @workspace Use atproto to check who I'm logged in as
   ```

   **Create a Post:**
   ```
   @workspace Use atproto to post "Testing MCP integration! #atproto #Bluesky"
   ```

   **Read Feed:**
   ```
   @workspace Use atproto to read my latest 5 posts from my feed
   ```

   **Search Posts:**
   ```
   @workspace Use atproto to search for posts about "AT Protocol"
   ```

### Verify Tool Discovery

The MCP server should register 29 tools. You can verify by checking the Copilot chat suggestions when you mention `@atproto` or `Use atproto`.

## Available MCP Tools

The atproto MCP server provides these tool categories:

### Authentication (4 tools)
- `auth_login` - Login to Bluesky
- `auth_logout` - Logout and clear session
- `auth_whoami` - Get current user info
- `auth_is_authenticated` - Check authentication status

### Content Management (5 tools)
- `post_create` - Create a new post (with hashtag support!)
- `post_reply` - Reply to a post
- `post_like` - Like a post
- `post_repost` - Repost content
- `post_delete` - Delete a post

### Feed Operations (4 tools)
- `feed_read` - Read your timeline
- `feed_search` - Search posts
- `feed_timeline` - Get timeline feed
- `feed_notifications` - Get notifications

### Profile Management (4 tools)
- `profile_get` - Get user profile
- `profile_follow` - Follow a user
- `profile_unfollow` - Unfollow a user
- `profile_block` - Block a user

### Search (3 tools)
- `search_posts` - Search for posts
- `search_users` - Find users
- `search_feeds` - Discover feeds

### Social Actions (6 tools)
- `follow_user` - Follow someone
- `unfollow_user` - Unfollow someone
- `block_user` - Block a user
- `unblock_user` - Unblock a user
- `get_followers` - List followers
- `get_following` - List following

### Media (3 tools)
- `upload_media` - Upload images/videos
- `post_with_image` - Create post with image
- `post_with_gallery` - Create post with multiple images

## Troubleshooting

### MCP Server Not Responding

1. Check if atproto is in PATH:
   ```bash
   which atproto
   ```

2. Test MCP server directly:
   ```bash
   echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"1.0.0"}}}' | atproto mcp-server
   ```

3. Check for Node.js:
   ```bash
   node --version
   ```

### Tools Not Appearing in Copilot

1. Verify MCP is enabled:
   - Check `github.copilot.chat.mcp.enabled` is `true` in settings

2. Reload VS Code:
   - `Ctrl+Shift+P` → `Developer: Reload Window`

3. Check Output panel:
   - `View` → `Output` → Select "GitHub Copilot Chat"

### Authentication Issues

1. Try logging in via CLI first:
   ```bash
   atproto logout
   atproto login
   ```

2. Check session file exists:
   ```bash
   ls -la ~/.config/atproto/session.json
   ```

3. Verify credentials are valid:
   ```bash
   atproto whoami
   ```

### Permission Errors

If you see permission errors accessing atproto:

```bash
# Fix installation permissions
sudo chown -R $USER:$USER ~/.config/atproto
chmod 600 ~/.config/atproto/session.json
```

## Advanced Configuration

### Custom PDS Endpoint

To use a custom AT Protocol server:

```json
{
  "github.copilot.chat.mcp.servers": {
    "atproto": {
      "command": "/usr/local/bin/atproto",
      "args": ["mcp-server"],
      "env": {
        "ATP_PDS": "https://your-custom-pds.example.com"
      }
    }
  }
}
```

### Enable Debug Logging

```json
{
  "github.copilot.chat.mcp.servers": {
    "atproto": {
      "command": "/usr/local/bin/atproto",
      "args": ["mcp-server"],
      "env": {
        "MCP_LOG_LEVEL": "debug",
        "DEBUG": "1"
      }
    }
  }
}
```

### Multiple Accounts

You can configure multiple atproto instances:

```json
{
  "github.copilot.chat.mcp.servers": {
    "atproto-personal": {
      "command": "/usr/local/bin/atproto",
      "args": ["mcp-server"]
    },
    "atproto-work": {
      "command": "/usr/local/bin/atproto",
      "args": ["mcp-server"],
      "env": {
        "CONFIG_DIR": "/home/user/.config/atproto-work"
      }
    }
  }
}
```

## Example Workflows

### Automated Posting

```
@workspace Use atproto to create a post about my latest commit with hashtags #coding #opensource
```

### Content Curation

```
@workspace Use atproto to search for posts about "TypeScript" and summarize the top 5
```

### Social Media Management

```
@workspace Use atproto to:
1. Check who I'm following
2. Search for users interested in "AI"
3. Follow the top 3 most relevant users
```

### Feed Analysis

```
@workspace Use atproto to read my last 20 feed items and create a summary of trending topics
```

## Next Steps

- Read [MCP_TOOLS.md](MCP_TOOLS.md) for detailed tool documentation
- Check [MCP_INTEGRATION.md](MCP_INTEGRATION.md) for integration patterns
- See [QUICKSTART_MCP.md](QUICKSTART_MCP.md) for quick reference

## Support

- GitHub Issues: https://github.com/p3nGu1nZz/atproto/issues
- Documentation: https://github.com/p3nGu1nZz/atproto
- Bluesky: Post with #atproto tag

---

*Last updated: October 31, 2025*
