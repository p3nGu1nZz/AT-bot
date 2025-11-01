# VS Code Copilot Integration Guide

This guide shows you how to integrate the atproto MCP server with GitHub Copilot in Visual Studio Code, enabling Copilot to interact with Bluesky directly from your editor.

## Prerequisites

- **VS Code** installed ([Download](https://code.visualstudio.com/))
- **GitHub Copilot** subscription and extension
- **atproto MCP server** installed globally
- **Node.js 18+** installed
- **Bluesky account** with app password

## Installation Steps

### 1. Install atproto MCP Server

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
# Output: /usr/local/bin/atproto-mcp-server

atproto-mcp-server --version
# Output: @atproto/mcp-server v0.1.0
```

### 3. Configure VS Code

#### Workspace Settings (Recommended)

Create or edit `.vscode/settings.json` in your project:

```json
{
  "github.copilot.advanced": {
    "mcp.servers": {
      "atproto": {
        "command": "atproto-mcp-server"
      }
    }
  }
}
```

#### User Settings (Global)

Or configure globally in VS Code settings:

1. Open Command Palette: `Cmd/Ctrl + Shift + P`
2. Type: "Preferences: Open User Settings (JSON)"
3. Add:

```json
{
  "github.copilot.advanced": {
    "mcp.servers": {
      "atproto": {
        "command": "atproto-mcp-server"
      }
    }
  }
}
```

### 4. Reload VS Code

**Important:** Reload the window for changes to take effect:
- Command Palette → "Developer: Reload Window"
- Or: `Cmd/Ctrl + R`

### 5. Verify MCP Server is Active

In VS Code:
1. Open Copilot Chat (Cmd/Ctrl + Shift + I)
2. Type: `@workspace /help`
3. Look for atproto tools in the list

## First Time Setup

### Authenticate with Bluesky

**Step 1: Generate App Password**

1. Visit [Bluesky Settings → App Passwords](https://bsky.app/settings/app-passwords)
2. Create new app password: "VS Code Copilot"
3. Copy the generated password

**Step 2: Login via Copilot**

In Copilot Chat:
```
@workspace Can you login to my Bluesky account?
Handle: yourname.bsky.social
```

Copilot will use the `auth_login` tool and prompt for password.

**Note:** Session persists across VS Code restarts.

## Usage Examples

### 1. Post from VS Code

**Scenario:** Share code snippet on Bluesky

In Copilot Chat:
```
Post this to Bluesky: "Just implemented a new feature! 
Check out the clean code pattern 🚀 #coding #atprotocol"
```

Copilot uses `post_create` and confirms success.

### 2. Share Release Notes

**Scenario:** Auto-post when releasing

Create a task in `.vscode/tasks.json`:
```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Post Release",
      "type": "shell",
      "command": "echo '${input:releaseNotes}' | xargs -I {} atproto post {}"
    }
  ],
  "inputs": [
    {
      "id": "releaseNotes",
      "type": "promptString",
      "description": "Release notes for Bluesky"
    }
  ]
}
```

Then ask Copilot:
```
Run the "Post Release" task and post our v1.0.0 release notes
```

### 3. Search Bluesky from Editor

**Scenario:** Research while coding

In Copilot Chat:
```
Search Bluesky for discussions about "TypeScript decorators" 
and summarize the best practices mentioned
```

Copilot uses `search_posts` and provides insights.

### 4. Monitor Project Mentions

**Scenario:** Track your project's mentions

In Copilot Chat:
```
Search Bluesky for mentions of "@myproject" and 
show me the recent feedback
```

### 5. Automated Engagement

**Scenario:** Follow contributors

In Copilot Chat:
```
Follow these Bluesky users who contributed to our project:
alice.bsky.social, bob.bsky.social, charlie.bsky.social
```

Copilot uses `batch_follow`.

## Advanced Configuration

### Environment Variables

Add environment variables to your VS Code settings:

```json
{
  "github.copilot.advanced": {
    "mcp.servers": {
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
}
```

**Variables:**
- `ATP_PDS` - AT Protocol server (default: https://bsky.social)
- `MCP_LOG_LEVEL` - DEBUG | INFO | WARN | ERROR
- `MCP_LOG_CONSOLE` - Enable console output

### Project-Specific Config

For team workflows, commit `.vscode/settings.json`:

```json
{
  "github.copilot.advanced": {
    "mcp.servers": {
      "atproto": {
        "command": "atproto-mcp-server",
        "env": {
          "ATP_PDS": "https://bsky.social"
        }
      }
    }
  },
  "tasks": [
    {
      "label": "Post Update",
      "type": "shell",
      "command": "atproto post '${input:message}'"
    }
  ]
}
```

Team members can then use consistent automation.

### Debug Mode

Enable debug logging in settings:

```json
{
  "github.copilot.advanced": {
    "mcp.servers": {
      "atproto": {
        "command": "atproto-mcp-server",
        "env": {
          "MCP_LOG_LEVEL": "DEBUG",
          "MCP_LOG_CONSOLE": "true"
        }
      }
    }
  }
}
```

View logs:
- **Output Panel** → "GitHub Copilot MCP"
- **Developer Tools** → Console (Cmd/Ctrl + Shift + I)

## Practical Workflows

### 1. Development Blog Automation

Create posts about development progress:

**Copilot Chat:**
```
Based on today's commits, write a Bluesky post summarizing 
our progress (max 280 chars) and post it with #devlog
```

### 2. CI/CD Integration

Post build status via GitHub Actions:

`.github/workflows/post-to-bluesky.yml`:
```yaml
name: Post to Bluesky
on:
  push:
    branches: [main]
jobs:
  post:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Node
        uses: actions/setup-node@v3
        with:
          node-version: 18
      - name: Install atproto
        run: npm install -g @atproto/mcp-server
      - name: Post Update
        env:
          BLUESKY_HANDLE: ${{ secrets.BLUESKY_HANDLE }}
          BLUESKY_PASSWORD: ${{ secrets.BLUESKY_PASSWORD }}
        run: |
          atproto login
          atproto post "✅ Build successful for commit: ${{ github.sha }}"
```

### 3. Code Review Sharing

Share interesting code reviews:

**Copilot Chat:**
```
Summarize this PR and create a Bluesky post highlighting 
the key improvements (tag with #codereview)
```

### 4. Documentation Updates

Auto-announce documentation changes:

**Copilot Chat:**
```
We just updated our API docs. Create a Bluesky post 
announcing the new documentation with a link
```

### 5. Community Engagement

Track and respond to community:

**Copilot Chat:**
```
Search Bluesky for questions about our project and 
show me the top 5 that need responses
```

## Keyboard Shortcuts

Create custom keybindings in `keybindings.json`:

```json
[
  {
    "key": "ctrl+alt+b",
    "command": "workbench.action.chat.open",
    "args": {
      "query": "@workspace Post to Bluesky: "
    }
  },
  {
    "key": "ctrl+alt+s",
    "command": "workbench.action.chat.open",
    "args": {
      "query": "@workspace Search Bluesky for: "
    }
  }
]
```

Usage:
- `Ctrl+Alt+B` - Quick post shortcut
- `Ctrl+Alt+S` - Quick search shortcut

## Troubleshooting

### Problem: atproto tools not available

**Solutions:**
1. Verify installation: `which atproto-mcp-server`
2. Check `.vscode/settings.json` syntax (must be valid JSON)
3. Reload VS Code window: Cmd/Ctrl + R
4. Check Output panel: "GitHub Copilot MCP"

### Problem: Command not found

**Solutions:**
1. Use full path in settings:
   ```json
   "command": "/usr/local/bin/atproto-mcp-server"
   ```
2. Add to PATH in settings:
   ```json
   "env": {
     "PATH": "${env:PATH}:/usr/local/bin"
   }
   ```

### Problem: Authentication fails

**Solutions:**
1. Generate new app password
2. Clear session: `atproto logout`
3. Re-authenticate via Copilot
4. Verify handle format: `username.bsky.social`

### Problem: Copilot doesn't see MCP servers

**Solution:**
GitHub Copilot MCP support varies by version. Ensure:
- Latest VS Code version
- Latest GitHub Copilot extension
- Copilot subscription active

Alternative: Use terminal integration:
```bash
# In VS Code terminal
atproto post "Direct CLI usage works too!"
```

## Best Practices

### 1. Workspace-Specific Settings

Use `.vscode/settings.json` for team consistency:
```json
{
  "github.copilot.advanced": {
    "mcp.servers": {
      "atproto": {
        "command": "atproto-mcp-server"
      }
    }
  }
}
```

Commit this file so team members get the same setup.

### 2. Security

**Never commit credentials:**
```json
// ❌ BAD - Don't do this
{
  "env": {
    "BLUESKY_PASSWORD": "my-password"
  }
}

// ✅ GOOD - Use app passwords and login once
{
  "command": "atproto-mcp-server"
}
```

### 3. Rate Limiting

Be mindful of API limits:
- Use batch operations for multiple actions
- Add delays between operations
- Monitor for 429 (rate limit) responses

### 4. Error Handling

Always check command outputs:
```
@workspace Post this message and confirm success or show errors
```

## Integration with Other Extensions

### Combine with GitHub PR Extension

```
@workspace Create a Bluesky post announcing this PR 
with key changes and link
```

### Combine with GitLens

```
@workspace Post a summary of this week's commits from GitLens
```

### Combine with REST Client

```
@workspace Search Bluesky for API discussions, then create 
a REST client request based on best practices found
```

## Resources

- [atproto Documentation](https://github.com/p3nGu1nZz/atproto)
- [MCP Tools Reference](../MCP_TOOLS.md)
- [VS Code API Docs](https://code.visualstudio.com/api)
- [GitHub Copilot Docs](https://docs.github.com/copilot)
- [AT Protocol Docs](https://atproto.com)

## Getting Help

- **Issues:** [GitHub Issues](https://github.com/p3nGu1nZz/atproto/issues)
- **Discussions:** [GitHub Discussions](https://github.com/p3nGu1nZz/atproto/discussions)
- **VS Code Extension:** [Marketplace Page](https://marketplace.visualstudio.com/items?itemName=atproto.vscode-atproto)

---

**Previous:** [← Claude Desktop Integration](CLAUDE_DESKTOP.md)
