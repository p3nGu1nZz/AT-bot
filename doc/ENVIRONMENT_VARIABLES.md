# AT-bot Environment Variables Reference

Complete reference for all environment variables supported by AT-bot.

## Table of Contents

- [Authentication](#authentication)
- [Configuration](#configuration)
- [Debugging](#debugging)
- [AT Protocol](#at-protocol)
- [Advanced](#advanced)

## Authentication

### BLUESKY_HANDLE

**Type**: String  
**Default**: None (prompts for input)  
**Purpose**: Bluesky handle for authentication

Automatically uses this handle when logging in instead of prompting.

```bash
export BLUESKY_HANDLE="user.bsky.social"
at-bot login  # Uses saved credentials or prompts for password only
```

**Use Cases:**
- Automation scripts
- CI/CD pipelines
- Batch operations

**Security Note**: Set temporarily; don't store in shell config files.

### BLUESKY_PASSWORD

**Type**: String  
**Default**: None (prompts for input securely)  
**Purpose**: App password for authentication

Provides password non-interactively. Use with **extreme caution**.

```bash
export BLUESKY_PASSWORD="abcd-efgh-ijkl-mnop"
at-bot login  # Non-interactive login
```

**Security Note**: 
- Only use with app passwords, never main password
- Set only for single command, never in shell config
- Consider using saved credentials instead (more secure)

**Best Practice**:
```bash
# Temporary for one command
BLUESKY_PASSWORD="$(cat ~/.bluesky_app_password)" at-bot login

# Or use saved credentials (encrypted)
at-bot login  # After first interactive login with save prompt
```

### BLUESKY_SESSION_FILE

**Type**: Path  
**Default**: `~/.config/at-bot/session.json`  
**Purpose**: Custom location for session storage

Store sessions in different locations for multiple accounts.

```bash
export BLUESKY_SESSION_FILE=~/.config/at-bot/work-session.json
at-bot login  # Saves to custom location

# Switch between sessions
export BLUESKY_SESSION_FILE=~/.config/at-bot/personal-session.json
at-bot whoami  # Shows personal account
```

## Configuration

### XDG_CONFIG_HOME

**Type**: Path  
**Default**: `~/.config`  
**Purpose**: Base directory for AT-bot configuration

Follows XDG Base Directory specification.

```bash
export XDG_CONFIG_HOME="$HOME/.myconfig"
at-bot login  # Uses ~/.myconfig/at-bot/session.json
```

**Directory Structure**:
```
$XDG_CONFIG_HOME/at-bot/
├── session.json        # Current session (encrypted)
├── credentials.json    # Saved credentials (encrypted)
└── mcp.json           # MCP server configuration
```

### PREFIX

**Type**: Path  
**Default**: `/usr/local`  
**Purpose**: Installation prefix for `install.sh`

Customize installation location.

```bash
PREFIX=$HOME/.local ./install.sh
# Installs to ~/.local/bin/at-bot and ~/.local/lib/at-bot/
```

**Common Values**:
- `/usr/local` - System-wide (requires sudo)
- `$HOME/.local` - User-only installation
- `$HOME/.opt` - Alternative local installation

## Debugging

### DEBUG

**Type**: Boolean (0/1 or empty)  
**Default**: Disabled  
**Purpose**: Enable detailed debug output

Shows internal debugging information for troubleshooting.

```bash
DEBUG=1 at-bot login
# Shows: function calls, API requests, credentials (encrypted)

DEBUG=1 at-bot post "test"
# Shows: session validation, API details, response parsing
```

**Debug Output Includes**:
- Function entry/exit
- Variable values (credentials masked)
- API requests and responses
- File operations
- Error details

**Security Note**: Debug output may contain sensitive data in development mode. Don't share debug logs publicly.

### DEBUG_API

**Type**: Boolean (0/1 or empty)  
**Default**: Disabled  
**Purpose**: Show raw API requests and responses

Even more detailed than DEBUG - shows HTTP details.

```bash
DEBUG_API=1 at-bot post "test"
# Shows: raw HTTP requests, full response bodies, headers
```

**Security Warning**: Shows all API traffic including tokens. Only use locally.

### VERBOSE

**Type**: Boolean (0/1 or empty)  
**Default**: Disabled  
**Purpose**: Verbose output for user feedback

More detailed but less technical than DEBUG.

```bash
VERBOSE=1 at-bot feed
# Shows: processing details, operation progress
```

## AT Protocol

### ATP_PDS

**Type**: URL  
**Default**: `https://bsky.social`  
**Purpose**: AT Protocol Personal Data Server endpoint

Use custom PDS or development instances.

```bash
# Use custom server
export ATP_PDS="https://custom.pds.example.com"
at-bot login
at-bot post "Posted to custom server"

# Use test instance
export ATP_PDS="https://staging.bsky.social"
at-bot login  # Use test credentials
```

**Common Values**:
- `https://bsky.social` - Production Bluesky
- `https://staging.bsky.social` - Staging/testing
- `http://localhost:3000` - Local development

### ATP_TIMEOUT

**Type**: Integer (seconds)  
**Default**: 30  
**Purpose**: HTTP request timeout

Set timeout for API requests.

```bash
# Longer timeout for slow connections
export ATP_TIMEOUT=60
at-bot feed

# Shorter timeout for quick fail
export ATP_TIMEOUT=5
at-bot whoami
```

**Useful For**:
- Slow network connections (increase)
- Quick response expectations (decrease)
- Testing timeout handling

### ATP_RETRY

**Type**: Integer (count)  
**Default**: 3  
**Purpose**: Number of retries for failed requests

Retry failed API calls.

```bash
# More retries for unreliable connections
export ATP_RETRY=5
at-bot post "Important"

# No retries for quick feedback
export ATP_RETRY=0
at-bot whoami
```

**Retry Behavior**:
- Exponential backoff between retries
- Skips permanent failures (4xx errors)
- Only retries transient failures (5xx, timeouts)

## Advanced

### SHELL

**Type**: String  
**Default**: Detected from system  
**Purpose**: Shell for subshell operations

Rarely needs to be set, but available for special cases.

```bash
export SHELL=/bin/bash
at-bot login
```

### HOME

**Type**: Path  
**Default**: User's home directory  
**Purpose**: User home directory location

Used for `~` expansion and config lookup. Usually set by system.

```bash
# Generally don't change this, but available if needed
export HOME=/tmp/testuser
```

### PATH

**Type**: Colon-separated paths  
**Default**: System PATH  
**Purpose**: Executable search path

Ensure `at-bot` is in PATH:

```bash
export PATH="/usr/local/bin:$PATH"
at-bot login
```

### LANG / LC_ALL

**Type**: Locale string  
**Default**: System locale  
**Purpose**: Language and character encoding

Affects output formatting and character handling.

```bash
# Force UTF-8
export LANG=en_US.UTF-8
at-bot feed

# Different locale
export LANG=fr_FR.UTF-8
at-bot whoami
```

## Common Combinations

### Complete Non-Interactive Login

```bash
#!/bin/bash
export BLUESKY_HANDLE="bot.bsky.social"
export BLUESKY_PASSWORD="$(cat /secure/location/password)"
export DEBUG=0
at-bot login
```

### Development Environment

```bash
#!/bin/bash
export DEBUG=1
export ATP_PDS="https://staging.bsky.social"
export ATP_TIMEOUT=60
export BLUESKY_SESSION_FILE=~/.config/at-bot/dev-session.json
at-bot login
```

### CI/CD Pipeline

```bash
#!/bin/bash
set -e
export BLUESKY_HANDLE="${BLUESKY_HANDLE}"
export BLUESKY_PASSWORD="${BLUESKY_PASSWORD}"
export ATP_TIMEOUT=30
export ATP_RETRY=3
at-bot login
at-bot post "CI/CD automated post"
```

### Multiple Accounts

```bash
#!/bin/bash

# Account 1
export BLUESKY_SESSION_FILE=~/.config/at-bot/account1.json
export BLUESKY_HANDLE="account1.bsky.social"
at-bot login

# Account 2
export BLUESKY_SESSION_FILE=~/.config/at-bot/account2.json
export BLUESKY_HANDLE="account2.bsky.social"
at-bot login

# Switch and operate
export BLUESKY_SESSION_FILE=~/.config/at-bot/account1.json
at-bot post "From account 1"

export BLUESKY_SESSION_FILE=~/.config/at-bot/account2.json
at-bot post "From account 2"
```

### Secure Automation

```bash
#!/bin/bash
# Load from secure storage (not in script)
eval $(vault read -format=json secret/atbot | jq -r '.data | to_entries | .[] | "export \(.key | ascii_upcase)=\(.value)"')

# Or from encrypted file
eval $(decrypt ~/.atbot.enc)

# Minimal debug (no credentials shown)
export DEBUG=0
at-bot login
at-bot post "Secure post"
```

## Variable Precedence

When multiple sources provide the same value:

1. **Command-line environment** (highest priority)
   ```bash
   BLUESKY_HANDLE="override" at-bot login
   ```

2. **Exported environment variables**
   ```bash
   export BLUESKY_HANDLE="exported"
   at-bot login
   ```

3. **Shell configuration files** (~/.bashrc, ~/.zshrc)
   ```bash
   # In ~/.bashrc
   export BLUESKY_HANDLE="config"
   ```

4. **Saved credentials**
   ```bash
   # In ~/.config/at-bot/credentials.json
   ```

5. **Interactive prompts** (lowest priority)
   ```bash
   # Prompts if not provided elsewhere
   ```

## Security Best Practices

### ✅ DO

- ✅ Use app passwords, not main passwords
- ✅ Set `BLUESKY_PASSWORD` temporarily for one command
- ✅ Use saved credentials (encrypted) when possible
- ✅ Store sensitive vars in secure vaults (HashiCorp Vault, AWS Secrets Manager)
- ✅ Use short-lived tokens in CI/CD
- ✅ Rotate credentials periodically

### ❌ DON'T

- ❌ Store `BLUESKY_PASSWORD` in shell config
- ❌ Commit credentials to git
- ❌ Use main Bluesky password with AT-bot
- ❌ Share debug logs containing credentials
- ❌ Store credentials in plain text
- ❌ Pass credentials through command-line history

## Troubleshooting

### Variables Not Working

```bash
# Check if variables are set
env | grep BLUESKY_

# Check if exported (in child processes)
bash -c 'echo $BLUESKY_HANDLE'

# Check precedence
at-bot whoami  # Uses current session/credentials
```

### Credentials Not Loading

```bash
# Check session file exists
ls -la $BLUESKY_SESSION_FILE

# Check config directory
ls -la $XDG_CONFIG_HOME/at-bot/

# Try explicit path
export BLUESKY_SESSION_FILE=~/.config/at-bot/session.json
at-bot whoami
```

### Debug Output Too Verbose

```bash
# Use VERBOSE instead of DEBUG
DEBUG=0 VERBOSE=1 at-bot login

# Or redirect to file
DEBUG=1 at-bot login > debug.log 2>&1
```

---

*Last updated: October 28, 2025*
