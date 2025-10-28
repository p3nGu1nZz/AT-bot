# AT-bot

A simple but powerful CLI tool and MCP server for Bluesky/AT Protocol automation, designed for both traditional users and AI agents.

## Overview

AT-bot provides two interfaces for interacting with Bluesky:

1. **CLI Interface** - Traditional command-line tool for users and scripts
2. **MCP Server Interface** - Model Context Protocol server for AI agents and automation

It provides simple authentication and session management, making it easy to automate Bluesky workflows from the command line or integrate with AI agents.

## Features

- 🔐 Secure login to Bluesky using the AT Protocol
- 💾 Session management with persistent authentication
- 🔐 AES-256-CBC encrypted credential storage (optional)
- 🛡️ Secure storage of session tokens (not passwords)
- 📝 Create posts and read your timeline
- 👥 Social interactions (follow, unfollow - coming soon)
- 💬 Simple, intuitive command-line interface
- 🏦 Optional local encrypted credential storage
- ⚙️ MCP server for AI agent integration (in development)
- 🐧 POSIX-compliant for Linux/WSL/Ubuntu environments
- 🔗 Fully compatible with Claude Copilot and other MCP-based tools

## Installation

### Quick Installation

Clone the repository and run the installation script:

```bash
git clone https://github.com/p3nGu1nZz/AT-bot.git
cd AT-bot
./install.sh
```

This will install AT-bot to `/usr/local/bin` by default. You may need sudo permissions.

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
at-bot login
```

You'll be prompted for your Bluesky handle and app password. Your session will be securely stored.

**Optional:** AT-bot will ask if you want to save your credentials for testing/automation. If you choose yes:
- Credentials are **encrypted** using AES-256-CBC
- Encryption key is stored securely with 600 permissions
- On next login, credentials are automatically decrypted
- This is useful for development but should be used carefully on shared systems

**Note:** Use an app password, not your main account password. You can generate app passwords in your Bluesky account settings.

### Check Current User

```bash
at-bot whoami
```

Displays information about the currently authenticated user.

### Create a Post

```bash
at-bot post "Hello Bluesky! 🚀"
```

Creates a new post on your Bluesky feed.

### Read Your Feed

```bash
# Read default (10 posts)
at-bot feed

# Read specific number of posts
at-bot feed 20
```

### Follow/Unfollow Users

```bash
# Follow a user
at-bot follow user.bsky.social

# Unfollow a user
at-bot unfollow user.bsky.social
```

### Search for Posts

```bash
# Search with default limit (10 results)
at-bot search "bluesky"

# Search with custom limit
at-bot search "AT Protocol" 25
```

### Clear Saved Credentials

```bash
at-bot clear-credentials
```

Removes any saved credentials (if you opted to save them during login).

### Logout

```bash
at-bot logout
```

Clears your session and logs you out.

### Help

```bash
at-bot help
# or
at-bot --help
```

Displays usage information and available commands.

## Environment Variables

You can optionally set credentials via environment variables for non-interactive usage:

```bash
export BLUESKY_HANDLE="your-handle.bsky.social"
export BLUESKY_PASSWORD="your-app-password"
at-bot login
```

**Security Note:** Only use environment variables in secure, trusted environments.

## Configuration

AT-bot includes a powerful configuration system for managing user preferences:

```bash
# View current configuration
at-bot config list

# Set configuration values
at-bot config set feed_limit 50
at-bot config set output_format json

# Get specific values
at-bot config get pds_endpoint

# Reset to defaults
at-bot config reset
```

### Configuration Options

- **pds_endpoint** - AT Protocol server URL (default: https://bsky.social)
- **output_format** - Output format: text or json (default: text)
- **color_output** - Color output: auto, always, or never (default: auto)
- **feed_limit** - Default number of feed posts (default: 20)
- **search_limit** - Default search results (default: 10)
- **debug** - Enable debug mode: true or false (default: false)

Configuration is stored in `~/.config/at-bot/config.json` and can be overridden with environment variables (e.g., `ATP_PDS`, `ATP_FEED_LIMIT`).

**For complete configuration documentation, see [doc/CONFIGURATION.md](doc/CONFIGURATION.md)**

### Session Storage

Session data is stored in `~/.config/at-bot/session.json`. This file contains your access tokens and should be kept secure (it's automatically set to mode 600).

## Automation & JSON Output

AT-bot supports JSON output for easy automation and scripting:

```bash
# Enable JSON output via config
at-bot config set output_format json

# Or use environment variable (no config change)
ATP_OUTPUT_FORMAT=json at-bot whoami
# Output: {"handle":"user.bsky.social","did":"did:plc:...","status":"authenticated"}

# Parse with jq for automation
ATP_OUTPUT_FORMAT=json at-bot whoami | jq -r '.handle'

# Create post and get URI
ATP_OUTPUT_FORMAT=json at-bot post "Hello!" | jq -r '.uri'

# Get feed data for processing
ATP_OUTPUT_FORMAT=json at-bot feed 50 | jq '.feed[].post.record.text'
```

### Automation Examples

**CI/CD Integration:**
```bash
# GitHub Actions, GitLab CI, etc.
export ATP_OUTPUT_FORMAT=json
export ATP_COLOR_OUTPUT=never
at-bot login
RESULT=$(at-bot post "Build #${BUILD_NUMBER} successful ✅")
echo "Posted: $(echo $RESULT | jq -r '.uri')"
```

**Scheduled Posts:**
```bash
#!/bin/bash
# daily-update.sh
export ATP_OUTPUT_FORMAT=json
at-bot login
at-bot post "📊 Daily Stats: $(generate_stats)" | jq -r '.uri' >> posted_uris.log
```

**For more automation patterns, see [AGENTS.md](AGENTS.md)**

### Session Storage

## Development

### Running Tests

```bash
make test
# or
bash tests/run_tests.sh
```

### Project Structure

```
AT-bot/
├── bin/          # Executable scripts
│   └── at-bot    # Main CLI tool
├── lib/          # Library functions
│   └── atproto.sh # AT Protocol implementation
├── tests/        # Test suite
│   ├── run_tests.sh
│   ├── test_cli_basic.sh
│   └── test_library.sh
├── doc/          # Documentation
├── Makefile      # Build/install automation
├── install.sh    # Installation script
└── README.md     # This file
```

## Uninstallation

### Using the installer

```bash
sudo rm -f /usr/local/bin/at-bot
sudo rm -rf /usr/local/lib/at-bot
sudo rm -rf /usr/local/share/doc/at-bot
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

AT-bot takes security seriously:

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
  - `at-bot clear-credentials` removes encrypted credentials and key
  - `at-bot logout` removes session tokens
  
- **All API communication** uses HTTPS
- **App-specific passwords** recommended for additional security

> **Production Note:** For production deployments, use environment variables or dedicated secret management services. The encrypted credential storage is designed for development and testing on personal machines. See [doc/ENCRYPTION.md](doc/ENCRYPTION.md) for threat model and security details.

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

## License

See the [LICENSE](LICENSE) file for details.

## Resources

- [AT Protocol Documentation](https://atproto.com/)
- [Bluesky](https://bsky.app/)
- [Project Repository](https://github.com/p3nGu1nZz/AT-bot)

## Troubleshooting

### Login fails

- Ensure you're using an app password, not your main account password
- Check that your handle is in the correct format (e.g., `user.bsky.social`)
- Verify you have an internet connection

### Command not found

- Make sure the installation directory is in your PATH
- Try running with the full path: `/usr/local/bin/at-bot`

### Permission denied

- Ensure the script has execute permissions: `chmod +x /usr/local/bin/at-bot`
- Check that the lib directory is readable
