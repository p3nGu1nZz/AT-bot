# AT-bot

A simple but versatile AT Protocol CLI tool for Bluesky automation and workflows.

## Overview

AT-bot is a POSIX-compliant command-line tool that allows you to interact with Bluesky using the AT Protocol. It provides simple authentication and session management, making it easy to automate Bluesky workflows from the command line.

## Features

- 🔐 Secure login to Bluesky using the AT Protocol
- 💾 Session management with persistent authentication
- 🛡️ Secure storage of session tokens (not passwords)
- 📝 Simple, intuitive command-line interface
- 🐧 POSIX-compliant for Linux/WSL/Ubuntu environments

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

**Note:** Use an app password, not your main account password. You can generate app passwords in your Bluesky account settings.

### Check Current User

```bash
at-bot whoami
```

Displays information about the currently authenticated user.

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

Session data is stored in `~/.config/at-bot/session.json` by default. This file contains your access tokens and should be kept secure (it's automatically set to mode 600).

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

- Passwords are never stored, only session tokens
- Session files are created with restrictive permissions (600)
- All API communication uses HTTPS
- Supports app-specific passwords for additional security

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
