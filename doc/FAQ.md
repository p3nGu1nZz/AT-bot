# atproto Frequently Asked Questions (FAQ)

Quick answers to common questions about installing, using, and troubleshooting atproto.

## Table of Contents

- [Installation](#installation)
- [Getting Started](#getting-started)
- [Usage](#usage)
- [Troubleshooting](#troubleshooting)
- [Security & Privacy](#security--privacy)
- [Advanced Usage](#advanced-usage)
- [Contributing](#contributing)

## Installation

### Q: What are the system requirements?

**A:** atproto requires:
- Bash 4.0 or higher
- curl (for HTTP requests)
- Standard Unix tools (grep, sed, awk)
- About 5-10 MB disk space

Optional for advanced features:
- Node.js 18+ (for MCP server development)
- pandoc (for documentation generation)

### Q: How do I install atproto?

**A:** Simple installation:

```bash
git clone https://github.com/p3nGu1nZz/atproto.git
cd atproto
./install.sh
```

Or to a custom location:
```bash
PREFIX=$HOME/.local ./install.sh
```

### Q: How do I uninstall atproto?

**A:** If you used the default installation:
```bash
sudo /usr/local/bin/uninstall.sh
```

Or manually remove:
```bash
sudo rm /usr/local/bin/atproto
sudo rm -rf /usr/local/lib/atproto
```

### Q: Does atproto work on Windows?

**A:** Yes! Use Windows Subsystem for Linux (WSL2):
```bash
wsl --install
# Then follow Linux installation steps
```

### Q: Does atproto work on macOS?

**A:** Yes! Install via:
```bash
./install.sh  # Standard installation
# or with Homebrew when available
brew install atproto
```

## Getting Started

### Q: How do I log in to Bluesky?

**A:** Use the login command:
```bash
atproto login
```

Then enter:
1. Your Bluesky handle (e.g., `user.bsky.social`)
2. Your app password (create one in Bluesky settings > App Passwords)

**Note**: Never use your main Bluesky password! Always use app passwords for security.

### Q: What's an app password?

**A:** An app password is a special password for third-party apps:
1. Go to Settings > App Passwords in Bluesky
2. Generate a new app password
3. Use it with atproto instead of your main password

Benefits:
- More secure than using your main password
- Can be revoked without changing main password
- Limits app permissions

### Q: How do I check if I'm logged in?

**A:** Use the whoami command:
```bash
atproto whoami
```

Shows your handle and user info if logged in.

### Q: How do I log out?

**A:** Use logout command:
```bash
atproto logout
```

This clears your session and any saved credentials.

## Usage

### Q: How do I post to Bluesky?

**A:** Create a post with:
```bash
atproto post "Your message here"
```

With line breaks:
```bash
atproto post "Line 1
Line 2
Line 3"
```

With media (when implemented):
```bash
atproto post-with-image "Message" image.jpg
```

### Q: How do I read my feed?

**A:** View your timeline:
```bash
atproto feed          # Show last 10 posts
atproto feed 20       # Show last 20 posts
```

### Q: How do I follow someone?

**A:** Use the follow command:
```bash
atproto follow username.bsky.social
```

Or unfollow:
```bash
atproto unfollow username.bsky.social
```

### Q: How do I search for posts?

**A:** Search posts or users:
```bash
atproto search "search query"
```

### Q: How do I reply to a post?

**A:** Reply using the post URI:
```bash
atproto reply at://did:plc:xxx/app.bsky.feed.post/xxx "Your reply"
```

You can get the URI from post listings.

### Q: How do I save my credentials for automation?

**A:** atproto can optionally save encrypted credentials:
```bash
atproto login
# When prompted: "Save credentials securely? (y/n): y"
```

Then future logins auto-load credentials:
```bash
atproto login  # Uses saved credentials automatically
```

To clear saved credentials:
```bash
atproto clear-credentials
```

**Security Note**: Credentials are encrypted with AES-256-CBC. Still use in trusted environments only.

### Q: How do I use environment variables for automation?

**A:** Set before running commands:
```bash
export BLUESKY_HANDLE="user.bsky.social"
export BLUESKY_PASSWORD="app-password-here"
atproto login
atproto post "Automated post!"
```

Perfect for scripts and CI/CD pipelines.

## Troubleshooting

### Q: I get "command not found: atproto"

**A:** atproto isn't in your PATH. Either:

1. Reinstall to system PATH:
   ```bash
   sudo ./install.sh
   ```

2. Or add to your shell config (~/.bashrc or ~/.zshrc):
   ```bash
   export PATH="/usr/local/bin:$PATH"
   source ~/.bashrc  # or ~/.zshrc
   ```

3. Or use full path:
   ```bash
   /usr/local/bin/atproto login
   ```

### Q: Login fails with "Invalid credentials"

**A:** Check:

1. **Handle is correct**: Use full handle with domain (e.g., `user.bsky.social`)
2. **Using app password**: Use app password from settings, not main password
3. **Account exists**: Verify your Bluesky account is active
4. **No typos**: Double-check password carefully
5. **Network connection**: Ensure internet connectivity

Debug with:
```bash
DEBUG=1 atproto login
```

### Q: Post fails with "Rate limited"

**A:** You've posted too frequently. Wait a few seconds and try again. Bluesky rate limits:
- Individual posts: ~5-10 seconds between posts
- Bulk operations: Lower limits than individual

### Q: I get "Session expired" errors

**A:** Your session token expired. Simply log in again:
```bash
atproto login
# Or use refresh if available:
atproto refresh
```

### Q: Commands hang or timeout

**A:** Network issue or Bluesky server slow. Try:

1. **Check internet**: `ping api.bsky.app`
2. **Retry**: Run command again
3. **Custom timeout** (when available):
   ```bash
   ATP_TIMEOUT=30 atproto feed
   ```

### Q: Permission denied when installing

**A:** Need sudo for system-wide installation:
```bash
sudo ./install.sh
```

Or install to home directory:
```bash
PREFIX=$HOME/.local ./install.sh
```

### Q: Where are my credentials stored?

**A:** In `~/.config/atproto/`:
- `session.json` - Current session token (encrypted)
- `credentials.json` - Saved credentials (encrypted)

Permissions set to 600 (user read/write only).

### Q: How do I enable debug output?

**A:** Set DEBUG environment variable:
```bash
DEBUG=1 atproto login
DEBUG=1 atproto post "Test"
```

Shows detailed debug output for troubleshooting.

### Q: Commands aren't working. What do I do?

**A:** Try these steps:

1. **Check installation**: `atproto --help`
2. **Check login**: `atproto whoami`
3. **Enable debugging**: `DEBUG=1 atproto <command>`
4. **Check logs**: Look in `~/.config/atproto/logs/` (if available)
5. **Report issue**: Open GitHub issue with debug output

## Security & Privacy

### Q: Is atproto safe to use?

**A:** Yes, with precautions:

✅ **Secure by default**:
- Credentials encrypted with AES-256-CBC
- Session tokens never printed
- Passwords read securely (hidden input)
- File permissions strictly enforced (600)

⚠️ **Best practices**:
- Use app passwords, never main password
- Don't share session/credential files
- Review code before using in automation
- Use in trusted environments only
- Keep atproto updated

### Q: Is my password stored?

**A:** No, passwords are not stored. Only:
- Session tokens (encrypted)
- Saved credentials (optional, encrypted)

Passwords are only used to obtain session tokens during login.

### Q: Can I audit what atproto does?

**A:** Yes! The entire codebase is open source:
- Read `lib/atproto.sh` to see all API calls
- Review `bin/atproto` for CLI implementation
- Enable DEBUG mode to see actual API requests

### Q: Is my data private?

**A:** atproto itself:
- Doesn't collect analytics
- Doesn't phone home
- Doesn't store your posts locally (except in command output)
- Respects your privacy

However:
- All data goes through Bluesky servers
- Follow Bluesky's privacy policy

### Q: How do I delete my data?

**A:** Remove local atproto data:

```bash
# Remove session and credentials
rm ~/.config/atproto/session.json
rm ~/.config/atproto/credentials.json

# Or completely remove atproto
atproto logout
uninstall.sh
rm -rf ~/.config/atproto
```

Bluesky stores your posts independently—delete from Bluesky directly.

### Q: Should I commit credentials to git?

**A:** Absolutely not! Add to `.gitignore`:

```bash
.env
.env.local
~/.config/atproto/
credentials.json
session.json
```

Or use environment variables instead:
```bash
export BLUESKY_HANDLE="..."
export BLUESKY_PASSWORD="..."
```

## Advanced Usage

### Q: Can I use atproto in scripts?

**A:** Yes! Use environment variables:

```bash
#!/bin/bash
export BLUESKY_HANDLE="bot.bsky.social"
export BLUESKY_PASSWORD="$APP_PASSWORD"
atproto login
atproto post "Automated daily post $(date)"
```

Or non-interactive with error handling:
```bash
if atproto login; then
    atproto post "Success!"
else
    echo "Login failed" >&2
    exit 1
fi
```

### Q: How do I use atproto with GitHub Actions?

**A:** Set up secrets and use in workflow:

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
      - name: Install atproto
        run: |
          git clone https://github.com/p3nGu1nZz/atproto.git
          cd atproto
          ./install.sh
      - name: Post to Bluesky
        env:
          BLUESKY_HANDLE: ${{ secrets.BLUESKY_HANDLE }}
          BLUESKY_PASSWORD: ${{ secrets.BLUESKY_PASSWORD }}
        run: |
          atproto login
          atproto post "🚀 New deployment!"
```

### Q: Can I use atproto with cron for scheduled posts?

**A:** Yes! Create a script:

```bash
#!/bin/bash
# ~/bin/post-daily.sh

source ~/.profile
export BLUESKY_HANDLE="bot.bsky.social"
export BLUESKY_PASSWORD="$(cat ~/.bluesky_password)"

atproto login
atproto post "Daily post: $(date)"
```

Then add to crontab:
```bash
crontab -e
# Add: 0 9 * * * /home/user/bin/post-daily.sh
```

### Q: How do I use the MCP server?

**A:** Configure MCP in your editor (VS Code, Claude, etc.):

```json
{
  "mcpServers": {
    "atproto": {
      "command": "atproto-mcp-server",
      "args": ["--config", "~/.config/atproto/mcp.json"]
    }
  }
}
```

Then use in AI agents and tools.

### Q: Can I use custom AT Protocol servers?

**A:** Yes, set the endpoint:

```bash
export ATP_PDS="https://custom.pds.example.com"
atproto login
```

Or use environment permanently in shell config.

### Q: What if I need to use a different shell?

**A:** atproto is bash-based, but you can call it from other shells:

```zsh
#!/bin/zsh
atproto login
atproto post "Posted from zsh!"
```

```fish
#!/usr/bin/fish
atproto login
atproto post "Posted from fish!"
```

Just ensure bash and dependencies are installed.

## Contributing

### Q: How do I contribute to atproto?

**A:** See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guide:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

### Q: What should I contribute?

**A:** We welcome:
- **Code**: Features, bug fixes, improvements
- **Testing**: Test cases, bug reports
- **Documentation**: Guides, examples, translations
- **Ideas**: Suggestions and feedback
- **Help**: Answering questions, community support

### Q: How do I report bugs?

**A:** Open a GitHub issue with:
1. Clear description
2. Steps to reproduce
3. Expected vs actual behavior
4. Your environment (OS, bash version, etc.)
5. Any error messages or logs

### Q: Can I request features?

**A:** Yes! Open a GitHub issue with:
1. Use case and problem you're trying to solve
2. Proposed solution
3. Any alternatives you've considered
4. Examples or mockups if applicable

---

## Still Have Questions?

- Check [README.md](../README.md) for overview
- Read [STYLE.md](../STYLE.md) for technical details
- Open a [GitHub Issue](https://github.com/p3nGu1nZz/atproto/issues)
- Start a [GitHub Discussion](https://github.com/p3nGu1nZz/atproto/discussions)
- See [CONTRIBUTING.md](CONTRIBUTING.md) for development

*Last updated: October 28, 2025*
