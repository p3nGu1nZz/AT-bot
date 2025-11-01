# atproto - AT Protocol CLI & VS Code Extension

[![npm version](https://img.shields.io/npm/v/@atproto/mcp-server.svg)](https://www.npmjs.com/package/@atproto/mcp-server)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Node.js Version](https://img.shields.io/node/v/@atproto/mcp-server.svg)](https://nodejs.org)

A simple but powerful CLI tool, MCP server, and VS Code extension for Bluesky/AT Protocol automation, designed for both traditional users and AI agents.

## Overview

atproto provides three interfaces for interacting with Bluesky:

1. **CLI Interface** - Traditional command-line tool for users and scripts
2. **MCP Server Interface** - Model Context Protocol server for AI agents and automation
3. **VS Code Extension** - Native VS Code integration with zero-configuration MCP server

It provides simple authentication and session management, making it easy to automate Bluesky workflows from the command line or integrate with AI agents.

## Features

- 🔐 Secure login to Bluesky using the AT Protocol
- 💾 Session management with persistent authentication
- 🔐 AES-256-CBC encrypted credential storage (optional)
- 🛡️ Secure storage of session tokens (not passwords)
- 📝 Create posts with automatic hashtag detection and formatting
- 📰 Read your timeline
- 👥 Social interactions (follow, unfollow, block, mute)
- 💬 Simple, intuitive command-line interface
- 🏦 Optional local encrypted credential storage
- 🤖 **MCP server with 29 tools for AI agents** (GitHub Copilot, Claude)
- 🎨 VS Code extension with zero-configuration setup
- 🐧 POSIX-compliant for Linux/WSL/Ubuntu environments
- 🔗 Fully compatible with Model Context Protocol (MCP)

## Installation

### Quick Install with MCP Server (Recommended)

Install atproto CLI and MCP server for AI agent integration:

```bash
git clone https://github.com/p3nGu1nZz/atproto.git
cd atproto
sudo ./install.sh --mcp
```

This installs:
- ✅ atproto CLI tool (`/usr/local/bin/atproto`)
- ✅ MCP server with 29 tools for AI agents
- ✅ All required dependencies

### CLI Only Installation

For command-line use without MCP server:

```bash
git clone https://github.com/p3nGu1nZz/atproto.git
cd atproto
sudo ./install.sh
```

### Custom Installation Location

To install to a custom location:

```bash
PREFIX=$HOME/.local ./install.sh
```

Then add `$HOME/.local/bin` to your PATH if not already present.

### Using Make

If you prefer using Make:

```bash
make install
```

Or for a custom location:

```bash
make install PREFIX=/custom/path
```

## Usage

### Login to Bluesky

```bash
atproto login
```

You'll be prompted for your Bluesky handle and app password. Your session will be securely stored.

**Optional:** atproto will ask if you want to save your credentials for testing/automation. If you choose yes:
- Credentials are **encrypted** using AES-256-CBC
- Encryption key is stored securely with 600 permissions
- On next login, credentials are automatically decrypted
- This is useful for development but should be used carefully on shared systems

**Note:** Use an app password, not your main account password. You can generate app passwords in your Bluesky account settings.

### Check Current User

```bash
atproto whoami
```

Displays information about the currently authenticated user.

### Create a Post

```bash
atproto post "Hello Bluesky! 🚀"

# Posts with hashtags (automatically detected and made clickable)
atproto post "Loving the #ATProtocol and #Bluesky! #OpenSource"
```

Creates a new post on your Bluesky feed. Hashtags are automatically detected and formatted as clickable links.

### Read Your Feed

```bash
# Read default (10 posts)
atproto feed

# Read specific number of posts
atproto feed 20
```

### Follow/Unfollow Users

```bash
# Follow a user
atproto follow user.bsky.social

# Unfollow a user
atproto unfollow user.bsky.social
```

### Search for Posts

```bash
# Search with default limit (10 results)
atproto search "bluesky"

# Search with custom limit
atproto search "AT Protocol" 25
```

### Clear Saved Credentials

```bash
atproto clear-credentials
```

Removes any saved credentials (if you opted to save them during login).

### Logout

```bash
atproto logout
```

Clears your session and logs you out.

### Help

```bash
atproto help
# or
atproto --help
```

Displays usage information and available commands.

## Environment Variables

You can optionally set credentials via environment variables for non-interactive usage:

```bash
export BLUESKY_HANDLE="your-handle.bsky.social"
export BLUESKY_PASSWORD="your-app-password"
atproto login
```

**Security Note:** Only use environment variables in secure, trusted environments.

## Configuration

atproto includes a powerful configuration system for managing user preferences:

```bash
# View current configuration
atproto config list

# Set configuration values
atproto config set feed_limit 50
atproto config set output_format json

# Get specific values
atproto config get pds_endpoint

# Reset to defaults
atproto config reset
```

### Configuration Options

- **pds_endpoint** - AT Protocol server URL (default: https://bsky.social)
- **output_format** - Output format: text or json (default: text)
- **color_output** - Color output: auto, always, or never (default: auto)
- **feed_limit** - Default number of feed posts (default: 20)
- **search_limit** - Default search results (default: 10)
- **debug** - Enable debug mode: true or false (default: false)

Configuration is stored in `~/.config/atproto/config.json` and can be overridden with environment variables (e.g., `ATP_PDS`, `ATP_FEED_LIMIT`).

**For complete configuration documentation, see [doc/CONFIGURATION.md](doc/CONFIGURATION.md)**

## MCP Server for AI Agents

atproto includes a Model Context Protocol (MCP) server that exposes 34 tools for AI agents like GitHub Copilot, Claude Desktop, and other MCP-compatible applications.

### Installation Options

**Option 1: npm (Easiest)**
```bash
npm install -g @atproto/mcp-server
```

**Option 2: From Source (Recommended for development)**
```bash
git clone https://github.com/p3nGu1nZz/atproto.git
cd atproto
sudo ./install.sh --mcp
```

### Quick Start with Claude Desktop

Add to your Claude Desktop config (`~/Library/Application Support/Claude/claude_desktop_config.json`):

```json
{
  "mcpServers": {
    "atproto": {
      "command": "atproto-mcp-server"
    }
  }
}
```

Restart Claude Desktop and you'll have access to all atproto tools!

**📖 Full Guide:** [docs/integrations/CLAUDE_DESKTOP.md](mcp-server/docs/integrations/CLAUDE_DESKTOP.md)

### Quick Start with VS Code Copilot

Add to your VS Code settings (`.vscode/settings.json` or user settings):

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

Reload VS Code and ask Copilot to interact with Bluesky!

**📖 Full Guide:** [docs/integrations/VSCODE_COPILOT.md](mcp-server/docs/integrations/VSCODE_COPILOT.md)

### Available MCP Tools (34 total)

The MCP server provides these categories of tools:

- **Authentication (4):** login, logout, whoami, is_authenticated
- **Content (5):** create post, reply, like, repost, delete
- **Feed (4):** read feed, search, timeline, notifications
- **Profile (4):** get profile, follow, unfollow, block
- **Social (6):** follow/unfollow user, block/unblock, get followers/following
- **Search (3):** search posts, users, timeline
- **Batch (5):** batch post, follow, unfollow, like, from file
- **Engagement (3):** like, repost, delete post

**📖 Complete Tool Documentation:** [mcp-server/docs/MCP_TOOLS.md](mcp-server/docs/MCP_TOOLS.md)

### Usage Examples

**With Claude Desktop:**
```
Can you post "Hello from AI! 🤖 #atprotocol" to my Bluesky account?
```

**With VS Code Copilot:**
```
@workspace Search Bluesky for posts about "MCP" and summarize the top 5
```

**With GitHub Actions:**
```yaml
- name: Post Release
  run: |
    npm install -g @atproto/mcp-server
    atproto login
    atproto post "🚀 New release v${{ github.ref_name }} is live!"
```

### Quick Start with GitHub Copilot (Legacy)

1. **Install with MCP support:**
   ```bash
   sudo ./install.sh --mcp
   ```

2. **Configure VS Code** (add to `.vscode/settings.json` or user settings):
   ```json
   {
     "github.copilot.chat.mcp.enabled": true,
     "github.copilot.chat.mcp.servers": {
       "atproto": {
         "command": "/usr/local/bin/atproto",
         "args": ["mcp-server"]
       }
     }
   }
   ```

3. **Reload VS Code:**
   - Press `Ctrl+Shift+P` → `Developer: Reload Window`

4. **Test in Copilot Chat:**
   ```
   @workspace Use atproto to check who I'm logged in as
   @workspace Use atproto to post "Hello from Copilot! #AI #Bluesky"
   ```

### MCP Tools Available

| Category | Tools |
|----------|-------|
| **Authentication** | login, logout, whoami, is_authenticated |
| **Content** | post_create, post_reply, post_like, post_repost, post_delete |
| **Feeds** | feed_read, feed_search, feed_timeline, feed_notifications |
| **Profile** | profile_get, profile_follow, profile_unfollow, profile_block |
| **Search** | search_posts, search_users, search_feeds |
| **Social** | follow_user, unfollow_user, block_user, get_followers, get_following |
| **Media** | upload_media, post_with_image, post_with_gallery |

### MCP Documentation

- **[VS Code Setup Guide](mcp-server/docs/VSCODE_SETUP.md)** - Complete setup instructions
- **[Quick Reference](mcp-server/docs/QUICKREF.md)** - Common commands and tips
- **[MCP Tools Documentation](mcp-server/docs/MCP_TOOLS.md)** - Detailed tool reference
- **[Integration Guide](mcp-server/docs/MCP_INTEGRATION.md)** - Integration patterns

### Session Storage

Session data is stored in `~/.config/atproto/session.json`. This file contains your access tokens and should be kept secure (it's automatically set to mode 600).

## Automation & JSON Output

atproto supports JSON output for easy automation and scripting:

```bash
# Enable JSON output via config
atproto config set output_format json

# Or use environment variable (no config change)
ATP_OUTPUT_FORMAT=json atproto whoami
# Output: {"handle":"user.bsky.social","did":"did:plc:...","status":"authenticated"}

# Parse with jq for automation
ATP_OUTPUT_FORMAT=json atproto whoami | jq -r '.handle'

# Create post and get URI
ATP_OUTPUT_FORMAT=json atproto post "Hello!" | jq -r '.uri'

# Get feed data for processing
ATP_OUTPUT_FORMAT=json atproto feed 50 | jq '.feed[].post.record.text'
```

### Automation Examples

**CI/CD Integration:**
```bash
# GitHub Actions, GitLab CI, etc.
export ATP_OUTPUT_FORMAT=json
export ATP_COLOR_OUTPUT=never
atproto login
RESULT=$(atproto post "Build #${BUILD_NUMBER} successful ✅")
echo "Posted: $(echo $RESULT | jq -r '.uri')"
```

**Scheduled Posts:**
```bash
#!/bin/bash
# daily-update.sh
export ATP_OUTPUT_FORMAT=json
atproto login
atproto post "📊 Daily Stats: $(generate_stats)" | jq -r '.uri' >> posted_uris.log
```

**For more automation patterns, see [AGENTS.md](AGENTS.md)**

### Session Storage

## Development

### Running Tests

Run the automated unit test suite:

```bash
make test-unit
# or
bash scripts/test-unit.sh
```

**Test Options:**
```bash
scripts/test-unit.sh --list          # List all 12 unit tests
scripts/test-unit.sh --verbose       # Show detailed test output
scripts/test-unit.sh test_cli        # Run specific tests
```

For more testing options and details, see **[TESTING.md](doc/TESTING.md)**.

### Project Structure

```
atproto/
├── bin/          # Executable scripts
│   └── atproto    # Main CLI tool
├── lib/          # Library functions
│   └── atproto.sh # AT Protocol implementation
├── scripts/      # Build and utility scripts
│   └── test-unit.sh # Unit test runner
├── tests/        # Unit test suite (12 tests)
│   ├── run_tests.sh
│   ├── test_cli_basic.sh
│   ├── test_encryption.sh
│   └── ... (10 more tests)
├── doc/          # Documentation
├── Makefile      # Build/install automation
├── install.sh    # Installation script
└── README.md     # This file
```

## Uninstallation

### Using the installer

```bash
sudo rm -f /usr/local/bin/atproto
sudo rm -rf /usr/local/lib/atproto
sudo rm -rf /usr/local/share/doc/atproto
```

### Using Make

```bash
make uninstall
```

## Requirements

- Bash 4.0 or higher
- curl
- grep
- Standard POSIX utilities

## Security

atproto takes security seriously:

- **Passwords are encrypted, not stored in plaintext**
  - Optional `--save` flag encrypts credentials with **AES-256-CBC** encryption
  - Industry-standard encryption with PBKDF2 key derivation and random salts
  - Encryption key stored separately with restrictive permissions (600)
  - **[See detailed encryption documentation](doc/ENCRYPTION.md)**
  
- **Session-based authentication**
  - Your password is only used once during login
  - Session tokens are stored with restricted permissions (mode 600)
  - Session tokens expire and can be revoked
  
- **Environment variables** supported for automation
  - Use `BLUESKY_HANDLE` and `BLUESKY_PASSWORD` for scripting
  - Avoids storing credentials on disk entirely
  
- **Clear commands** to remove stored data
  - `atproto clear-credentials` removes encrypted credentials and key
  - `atproto logout` removes session tokens
  
- **All API communication** uses HTTPS
- **App-specific passwords** recommended for additional security

> **Production Note:** For production deployments, use environment variables or dedicated secret management services. The encrypted credential storage is designed for development and testing on personal machines. See [doc/ENCRYPTION.md](doc/ENCRYPTION.md) for threat model and security details.

## Documentation

### Quick Reference Guides

- **[QUICKSTART.md](doc/QUICKSTART.md)** - Quick start guide to get up and running in 5 minutes
- **[MCP_QUICKSTART.md](doc/MCP_QUICKSTART.md)** - 🆕 **MCP Server Quick Start** - Get AI agents working with atproto in 5 minutes
- **[FAQ.md](doc/FAQ.md)** - Frequently asked questions about installation, usage, troubleshooting, and security
- **[EXAMPLES.md](doc/EXAMPLES.md)** - Practical code examples and automation scripts
- **[ENVIRONMENT_VARIABLES.md](doc/ENVIRONMENT_VARIABLES.md)** - Complete reference for all supported environment variables

### Technical Documentation

- **[SECURITY.md](SECURITY.md)** - Security policies, threat model, and best practices
- **[ENCRYPTION.md](doc/ENCRYPTION.md)** - Detailed encryption implementation and cryptographic details
- **[DEBUG_MODE.md](doc/DEBUG_MODE.md)** - Debugging guide with examples
- **[TESTING.md](doc/TESTING.md)** - Testing strategy and how to run tests
- **[ARCHITECTURE.md](doc/ARCHITECTURE.md)** - System design and architecture overview

### Development Guides

- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Contributor guidelines, development setup, and code review process
- **[STYLE.md](STYLE.md)** - Coding standards and conventions
- **[PLAN.md](PLAN.md)** - Strategic roadmap and architecture evolution
- **[AGENTS.md](AGENTS.md)** - AI agent integration patterns and automation opportunities

### Complete Documentation Package

Generate a comprehensive, professionally formatted PDF containing all project documentation:

```bash
make docs
```

This creates:
- **PDF** - Complete documentation in a single shareable file
- **HTML** - Web-friendly version with styling
- **Markdown** - Combined source document

The generated "atproto Complete Documentation" PDF is perfect for:
- Onboarding new contributors
- Offline reference
- Project presentations
- Archive distribution

See [doc/DOCUMENTATION.md](doc/DOCUMENTATION.md) for details.

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

## License

See the [LICENSE](LICENSE) file for details.

## Resources

- [AT Protocol Documentation](https://atproto.com/)
- [Bluesky](https://bsky.app/)
- [Project Repository](https://github.com/p3nGu1nZz/atproto)

## Troubleshooting

### Login fails

- Ensure you're using an app password, not your main account password
- Check that your handle is in the correct format (e.g., `user.bsky.social`)
- Verify you have an internet connection

### Command not found

- Make sure the installation directory is in your PATH
- Try running with the full path: `/usr/local/bin/atproto`

### Permission denied

- Ensure the script has execute permissions: `chmod +x /usr/local/bin/atproto`
- Check that the lib directory is readable
