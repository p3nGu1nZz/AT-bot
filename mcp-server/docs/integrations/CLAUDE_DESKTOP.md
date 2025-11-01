# Claude Desktop Integration Guide

This guide walks you through setting up the atproto MCP server with Claude Desktop, enabling Claude to interact with Bluesky directly.

## Prerequisites

- **Claude Desktop** installed ([Download here](https://claude.ai/download))
- **atproto MCP server** installed globally
- **Node.js 18+** installed
- **Bluesky account** with app password

## Installation Steps

### 1. Install atproto MCP Server

Choose one of these methods:

**Option A: npm (Recommended)**
```bash
npm install -g @atproto/mcp-server
```

**Option B: From Source**
```bash
git clone https://github.com/p3nGu1nZz/atproto.git
cd atproto
./install.sh
```

### 2. Verify Installation

```bash
which atproto-mcp-server
# Should output: /usr/local/bin/atproto-mcp-server (or similar)

atproto-mcp-server --version
# Should output: @atproto/mcp-server v0.1.0
```

### 3. Configure Claude Desktop

#### macOS

1. **Locate config file:**
   ```bash
   open ~/Library/Application\ Support/Claude/
   ```

2. **Edit or create** `claude_desktop_config.json`:
   ```bash
   nano ~/Library/Application\ Support/Claude/claude_desktop_config.json
   ```

3. **Add configuration:**
   ```json
   {
     "mcpServers": {
       "atproto": {
         "command": "atproto-mcp-server"
       }
     }
   }
   ```

#### Windows

1. **Locate config file:**
   ```
   %APPDATA%\Claude\claude_desktop_config.json
   ```

2. **Add configuration:**
   ```json
   {
     "mcpServers": {
       "atproto": {
         "command": "atproto-mcp-server.cmd"
       }
     }
   }
   ```

#### Linux

1. **Locate config file:**
   ```bash
   ~/.config/Claude/claude_desktop_config.json
   ```

2. **Add configuration:**
   ```json
   {
     "mcpServers": {
       "atproto": {
         "command": "atproto-mcp-server"
       }
     }
   }
   ```

### 4. Restart Claude Desktop

**Important:** Completely quit and restart Claude Desktop:

- **macOS:** `Cmd+Q` then relaunch
- **Windows:** Right-click system tray → Exit, then relaunch
- **Linux:** `killall claude` then relaunch

### 5. Verify MCP Server is Loaded

In Claude Desktop, you should see:
- A small indicator that MCP servers are active (check status bar)
- Access to atproto tools when you ask Claude to interact with Bluesky

## First Time Usage

### Authenticate with Bluesky

**Step 1: Get an App Password**

1. Go to [Bluesky Settings → App Passwords](https://bsky.app/settings/app-passwords)
2. Click "Add App Password"
3. Name it: "Claude Desktop - atproto"
4. Copy the generated password (you won't see it again!)

**Step 2: Login via Claude**

In Claude Desktop, say:
```
Can you login to my Bluesky account?
Handle: yourname.bsky.social
```

Claude will prompt for your app password. Paste it when asked.

**Note:** Your session is stored securely (AES-256 encrypted) and persists across Claude restarts.

## Example Usage

### 1. Create a Post

**You:**
```
Post this to Bluesky: "Just set up Claude Desktop with atproto MCP! 
AI agents can now interact with decentralized social media 🚀 #atprotocol #MCP"
```

**Claude will:**
- Use `post_create` tool
- Automatically detect hashtags and mentions
- Return the post URI
- Confirm success

### 2. Read Your Timeline

**You:**
```
What's happening on my Bluesky timeline?
```

**Claude will:**
- Use `feed_read` or `feed_timeline` tool
- Retrieve recent posts
- Summarize interesting content
- Show who's posting what

### 3. Search and Analyze

**You:**
```
Search Bluesky for posts about "Model Context Protocol" and summarize the top 5 results
```

**Claude will:**
- Use `search_posts` tool
- Retrieve matching posts
- Analyze content
- Provide a summary with key insights

### 4. Follow Users

**You:**
```
Can you follow these Bluesky users: alice.bsky.social, bob.bsky.social
```

**Claude will:**
- Use `batch_follow` or `follow_user` tool
- Follow each user
- Confirm completion

### 5. Get Your Profile Stats

**You:**
```
Show me my Bluesky profile stats
```

**Claude will:**
- Use `profile_get` tool
- Display followers, following, posts count
- Show account creation date
- Present formatted stats

## Advanced Configuration

### Environment Variables

Add environment variables to your config for advanced control:

```json
{
  "mcpServers": {
    "atproto": {
      "command": "atproto-mcp-server",
      "env": {
        "ATP_PDS": "https://bsky.social",
        "MCP_LOG_LEVEL": "INFO",
        "MCP_LOG_CONSOLE": "false"
      }
    }
  }
}
```

**Available Variables:**
- `ATP_PDS` - AT Protocol server (default: https://bsky.social)
- `MCP_LOG_LEVEL` - DEBUG, INFO, WARN, ERROR (default: INFO)
- `MCP_LOG_CONSOLE` - Enable console logging (default: false)

### Debug Mode

To troubleshoot issues, enable debug logging:

```json
{
  "mcpServers": {
    "atproto": {
      "command": "atproto-mcp-server",
      "env": {
        "MCP_LOG_LEVEL": "DEBUG",
        "MCP_LOG_CONSOLE": "true"
      }
    }
  }
}
```

Then check Claude's logs:
- **macOS:** `~/Library/Logs/Claude/mcp*.log`
- **Windows:** `%APPDATA%\Claude\Logs\mcp*.log`
- **Linux:** `~/.local/share/Claude/logs/mcp*.log`

## Troubleshooting

### Problem: atproto tools not appearing

**Solutions:**
1. Verify installation: `which atproto-mcp-server`
2. Check config file location and syntax (must be valid JSON)
3. Ensure command path is correct in config
4. Completely restart Claude Desktop (don't just close window)
5. Check Claude logs for error messages

### Problem: "command not found" error

**Solutions:**
1. Reinstall: `npm install -g @atproto/mcp-server`
2. Add to PATH:
   ```bash
   export PATH="$PATH:/usr/local/bin"
   ```
3. Use full path in config:
   ```json
   {
     "mcpServers": {
       "atproto": {
         "command": "/usr/local/bin/atproto-mcp-server"
       }
     }
   }
   ```

### Problem: Authentication fails

**Solutions:**
1. Generate new app password at [bsky.app/settings/app-passwords](https://bsky.app/settings/app-passwords)
2. Clear session and re-login:
   ```bash
   atproto logout
   ```
   Then login again via Claude
3. Verify handle format: `username.bsky.social` (not @username)

### Problem: "Session expired" errors

**Solution:**
Sessions refresh automatically. If issues persist:
```bash
atproto logout
```
Then authenticate again via Claude.

### Problem: Rate limiting

**Solution:**
atproto respects AT Protocol rate limits with exponential backoff. If you hit limits:
- Wait a few minutes before retrying
- Reduce batch operation sizes
- Spread operations over time

## Security Best Practices

### 1. Use App Passwords (Not Main Password)
Always use app passwords from [Bluesky Settings](https://bsky.app/settings/app-passwords). Benefits:
- Can revoke without changing main password
- Limited scope
- Can create multiple for different purposes

### 2. Never Share Credentials
- Don't paste credentials in shared conversations
- Don't commit config files with passwords
- Rotate app passwords periodically

### 3. Verify Session Storage
Session files are encrypted (AES-256-CBC) and stored:
- **Location:** `~/.config/atproto/session.json`
- **Permissions:** 600 (owner read/write only)
- **Content:** Encrypted tokens (not passwords)

### 4. Monitor Usage
Review Claude's activity periodically:
```
Show me my recent Bluesky posts
```

## What's Next?

### Explore Advanced Features

1. **Batch Operations:**
   ```
   Create 5 daily update posts for this week
   ```

2. **Scheduled Content:**
   ```
   Generate a week's worth of motivational posts about AI and decentralization
   ```

3. **Analytics:**
   ```
   Analyze my Bluesky engagement over the past week
   ```

4. **Content Curation:**
   ```
   Find and summarize trending posts about MCP on Bluesky
   ```

### Integrate with Other Tools

Combine atproto with other MCP servers for powerful workflows:
- **File system** → Post content from local files
- **Web search** → Research topics, then post summaries
- **GitHub** → Share release notes on Bluesky
- **Slack** → Cross-post important updates

### Build Custom Workflows

Create sophisticated automation:
```
Every morning, read my Bluesky timeline, summarize key updates,
and create a digest post with highlights
```

## Resources

- [atproto Documentation](https://github.com/p3nGu1nZz/atproto)
- [MCP Tools Reference](../MCP_TOOLS.md)
- [AT Protocol Docs](https://atproto.com)
- [Bluesky Help](https://bsky.social)
- [Model Context Protocol Spec](https://modelcontextprotocol.io)

## Getting Help

- **Issues:** [GitHub Issues](https://github.com/p3nGu1nZz/atproto/issues)
- **Discussions:** [GitHub Discussions](https://github.com/p3nGu1nZz/atproto/discussions)
- **Updates:** Follow [@atproto](https://bsky.app/profile/atproto.bsky.social) on Bluesky

---

**Next:** [VS Code Copilot Integration →](VSCODE_COPILOT.md)
