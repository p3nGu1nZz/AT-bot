# AT-bot Quick Start Guide

This guide will help you get started with AT-bot quickly.

## Prerequisites

- Linux, macOS, or Windows with WSL
- Bash shell
- curl installed
- A Bluesky account
- An app password from your Bluesky account

## Step 1: Generate an App Password

1. Log in to your Bluesky account at https://bsky.app/
2. Go to Settings → App Passwords
3. Click "Add App Password"
4. Give it a name (e.g., "AT-bot CLI")
5. Copy the generated password

**Important:** Use app passwords, not your main account password!

## Step 2: Install AT-bot

Clone and install:

```bash
git clone https://github.com/p3nGu1nZz/AT-bot.git
cd AT-bot
./install.sh
```

## Step 3: Login

```bash
at-bot login
```

Enter your Bluesky handle (e.g., `yourname.bsky.social`) and the app password you generated.

## Step 4: Verify Login

```bash
at-bot whoami
```

You should see your handle and DID (Decentralized Identifier).

## Next Steps

- Explore available commands with `at-bot help`
- Check out the main README.md for detailed documentation
- Look at the lib/atproto.sh file to understand the API integration

## Troubleshooting

### "curl: command not found"

Install curl:
```bash
# Ubuntu/Debian
sudo apt-get install curl

# macOS
brew install curl
```

### "Permission denied"

Make sure the script is executable:
```bash
chmod +x /usr/local/bin/at-bot
```

### "Login failed: Invalid identifier or password"

- Double-check your handle format (should include .bsky.social)
- Make sure you're using an app password, not your main password
- Verify the app password hasn't expired
