# Quick Start: AT-bot MCP Server

Get up and running with AT-bot MCP server in 5 minutes.

## What is MCP?

**Model Context Protocol** is a standard way for AI agents (like Claude) to interact with tools and data sources. With AT-bot's MCP server, agents can post to Bluesky, read feeds, follow users, and more.

## Installation

### Prerequisites

- Node.js 16+ or Python 3.8+
- AT-bot installed (`/usr/local/bin/at-bot` or development version)
- Bluesky account with app password

### Install MCP Server

```bash
# From AT-bot repository
cd mcp-server
npm install              # or: pip install -r requirements.txt

# Install to system
npm run install          # or: make install
```

### Or Use Pre-built Binary

```bash
# Homebrew (coming soon)
brew install at-bot-mcp-server

# npm global
npm install -g at-bot-mcp-server

# Standalone executable
# Download from releases page
chmod +x at-bot-mcp-server
```

## Configure Bluesky Authentication

### Step 1: Generate App Password

1. Go to https://bsky.app
2. Settings → Account → App passwords
3. Create new app password
4. Copy the password (you'll only see it once!)

### Step 2: Authenticate AT-bot

```bash
# Option A: Interactive
at-bot login
# Prompts for handle and password

# Option B: Environment variables (for automation)
export BLUESKY_HANDLE="yourhandle.bsky.social"
export BLUESKY_PASSWORD="xxxx-xxxx-xxxx-xxxx"
at-bot login
```

### Step 3: Verify Authentication

```bash
at-bot whoami
# Should show your profile info
```

## Configure with Copilot/Claude

### Option 1: VS Code Copilot

Create or update `.vscode/settings.json`:

```json
{
  "github.copilot.enable": {
    "*": true
  },
  "mcp.servers": {
    "at-bot": {
      "command": "at-bot-mcp-server",
      "args": [],
      "env": {
        "ATP_PDS": "https://bsky.social"
      }
    }
  }
}
```

Restart VS Code and Copilot will automatically discover AT-bot tools.

### Option 2: Claude Projects (Claude.ai)

1. Create new Claude project
2. Go to Project Settings → MCP Servers
3. Add server:
   - Name: `at-bot`
   - Command: `at-bot-mcp-server`
   - Keep args and env as shown above
4. Click "Connect"

### Option 3: Manual Configuration

If using a custom MCP client:

```bash
# Start MCP server manually (connects via stdio)
at-bot-mcp-server

# In your agent code, connect to stdio
# and discover tools
```

## First Commands

### Via CLI (traditional)

```bash
# Create a post
at-bot post "Hello world! 🚀"

# Read your timeline
at-bot feed

# Follow someone
at-bot follow alice.bsky.social
```

### Via Copilot (MCP)

In VS Code or Claude:

```
You: "Post a message to Bluesky saying hello"

Claude: 
I'll post a message to Bluesky for you.
[Uses post_create tool]
✓ Posted successfully!
```

## Available Tools

**Authentication**
- `auth_login` - Log in to Bluesky
- `auth_logout` - Log out
- `auth_whoami` - Show current user
- `auth_is_authenticated` - Check if logged in

**Posts**
- `post_create` - Create a post
- `post_reply` - Reply to a post
- `post_like` - Like a post
- `post_repost` - Repost content
- `post_delete` - Delete a post

**Feeds**
- `feed_read` - Read your feed
- `feed_search` - Search posts
- `feed_timeline` - View user's timeline
- `feed_notifications` - Get your notifications

**Profiles**
- `profile_get` - Get user profile
- `profile_follow` - Follow someone
- `profile_unfollow` - Unfollow
- `profile_block` - Block user
- `profile_unblock` - Unblock user

For detailed tool documentation, see [MCP_TOOLS.md](MCP_TOOLS.md)

## Common Tasks

### Task: Daily Status Updates

```
You: "Create a daily status update bot that posts at 9am"

Claude:
I can help set that up. Here's what we'll do:
1. Create a script that generates your daily status
2. Schedule it to run at 9am
3. Use the post_create tool to publish

[Creates scheduled task using post_create]
```

### Task: Monitor Mentions

```
You: "Set up a bot to alert me when I'm mentioned"

Claude:
I'll set up monitoring using the feed_notifications tool:
1. Check notifications regularly
2. Filter for mentions
3. Alert you when found

[Configures agent to run feed_notifications periodically]
```

### Task: Follow New Followers

```
You: "Follow everyone who follows me"

Claude:
I'll use profile_get and profile_follow to:
1. Get your followers list
2. Follow each one back
3. Report completion

[Uses tools to establish follows]
```

## Troubleshooting

### "Not authenticated" Error

```bash
# Check if session exists
at-bot whoami

# If not, log in
at-bot login

# Verify session file
ls -la ~/.config/at-bot/session.json
```

### MCP Server Won't Start

```bash
# Check logs
export MCP_LOG_LEVEL=debug
at-bot-mcp-server

# Verify tools are discoverable
curl http://localhost:3000/_meta/capabilities
```

### Permission Denied

```bash
# Make sure script is executable
chmod +x /usr/local/bin/at-bot-mcp-server

# Check file permissions
ls -la /usr/local/lib/at-bot/
```

### Agent Can't Find Tools

```bash
# Restart VS Code or Claude
# Check MCP server is running
ps aux | grep at-bot-mcp

# Verify configuration
cat ~/.config/at-bot/mcp.json
```

## Next Steps

1. **Read Full Documentation**
   - [MCP_INTEGRATION.md](MCP_INTEGRATION.md) - Detailed integration guide
   - [MCP_TOOLS.md](MCP_TOOLS.md) - All tool schemas
   - [ARCHITECTURE.md](ARCHITECTURE.md) - Technical design

2. **Try Advanced Workflows**
   - Multi-step agent automation
   - Batch operations
   - Scheduled tasks
   - Event-driven workflows

3. **Contribute**
   - Report bugs and issues
   - Suggest new tools
   - Share your workflows
   - Contribute code

## Security Best Practices

1. **Use App Passwords**
   - Never use your main account password
   - Create separate app passwords for different agents
   - Rotate passwords regularly

2. **Protect Session Files**
   - Session stored at `~/.config/at-bot/session.json`
   - File permissions set to 600 (owner only)
   - Never commit session files to git

3. **Monitor Activity**
   - Check logs regularly: `~/.config/at-bot/logs/`
   - Review notification logs
   - Set rate limits on agent actions

4. **Limit Agent Permissions**
   - Each agent gets minimal required permissions
   - Read-only agents for monitoring
   - Write-only agents for posting
   - No cross-agent access

## Support & Help

- **Docs:** See [doc/](doc/) directory
- **Issues:** GitHub issue tracker
- **Security:** See [doc/SECURITY.md](doc/SECURITY.md)
- **Contributing:** See [doc/CONTRIBUTING.md](doc/CONTRIBUTING.md)

## What's Next?

- Implement MCP server core
- Deploy to package registries
- Build community integrations
- Create agent marketplace

See [PLAN.md](PLAN.md) for full roadmap.

---

**Ready to control Bluesky with AI?** 🚀

Start by authenticating: `at-bot login`

Then configure with Copilot and begin building amazing AI workflows!

*Last updated: October 28, 2025*