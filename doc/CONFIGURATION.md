# atproto Configuration Guide

This guide explains how to use atproto's configuration system to customize your experience.

## Overview

atproto uses a JSON configuration file to store user preferences. The configuration system supports:

- **Default values** for all commands
- **Environment variable overrides** for automation
- **Validation** to prevent invalid configurations
- **Easy management** through CLI commands

## Configuration File

**Location**: `~/.config/atproto/config.json`

**Default Content**:
```json
{
  "pds_endpoint": "https://bsky.social",
  "output_format": "text",
  "color_output": "auto",
  "feed_limit": 20,
  "search_limit": 10,
  "debug": false
}
```

## Configuration Options

### `pds_endpoint`
**Type**: String (URL)  
**Default**: `https://bsky.social`  
**Description**: The AT Protocol Personal Data Server (PDS) endpoint to connect to.

**Use Cases**:
- Connect to custom PDS instances
- Development/testing against local servers
- Use alternative AT Protocol implementations

**Examples**:
```bash
atproto config set pds_endpoint https://bsky.social
atproto config set pds_endpoint https://my-custom-pds.example.com
```

### `output_format`
**Type**: String (`text` or `json`)  
**Default**: `text`  
**Description**: Format for command output.

**Values**:
- `text` - Human-readable formatted output (default)
- `json` - Machine-readable JSON output (for scripting)

**Examples**:
```bash
atproto config set output_format text   # Human-readable
atproto config set output_format json   # Machine-readable
```

### `color_output`
**Type**: String (`auto`, `always`, or `never`)  
**Default**: `auto`  
**Description**: Control color output in terminal.

**Values**:
- `auto` - Use colors if terminal supports it (default)
- `always` - Always use colors
- `never` - Never use colors (useful for logs/pipes)

**Examples**:
```bash
atproto config set color_output auto    # Detect automatically
atproto config set color_output always  # Force colors
atproto config set color_output never   # Plain text only
```

### `feed_limit`
**Type**: Integer (1-100)  
**Default**: `20`  
**Description**: Default number of posts to retrieve when reading your feed.

**Examples**:
```bash
atproto config set feed_limit 10   # Quick check
atproto config set feed_limit 50   # Deep dive
atproto config set feed_limit 100  # Maximum
```

### `search_limit`
**Type**: Integer (1-100)  
**Default**: `10`  
**Description**: Default number of results to return when searching.

**Examples**:
```bash
atproto config set search_limit 5    # Quick search
atproto config set search_limit 25   # Detailed search
```

### `debug`
**Type**: Boolean (`true` or `false`)  
**Default**: `false`  
**Description**: Enable debug mode to show detailed operation information.

**Examples**:
```bash
atproto config set debug true    # Enable debug output
atproto config set debug false   # Disable debug output
```

## CLI Commands

### List Configuration
Show all current configuration values:

```bash
atproto config list
```

**Output**:
```
Current Configuration:
=====================

PDS Endpoint:    https://bsky.social
Output Format:   text
Color Output:    auto
Feed Limit:      20
Search Limit:    10
Debug Mode:      false

Config file: /home/user/.config/atproto/config.json
```

### Get Configuration Value
Retrieve a specific configuration value:

```bash
atproto config get <key>
```

**Examples**:
```bash
atproto config get feed_limit
# Output: 20

atproto config get pds_endpoint
# Output: https://bsky.social
```

### Set Configuration Value
Update a configuration value:

```bash
atproto config set <key> <value>
```

**Examples**:
```bash
atproto config set feed_limit 50
# Output: Configuration updated: feed_limit = 50

atproto config set color_output never
# Output: Configuration updated: color_output = never
```

### Reset Configuration
Reset all configuration to default values:

```bash
atproto config reset
```

**Output**:
```
Backup created: /home/user/.config/atproto/config.json.backup
Configuration reset to defaults

Current Configuration:
=====================
...
```

**Note**: A backup of your current configuration is automatically created.

### Validate Configuration
Check if your configuration file is valid:

```bash
atproto config validate
```

**Output** (if valid):
```
Configuration is valid
```

**Output** (if invalid):
```
Configuration has errors. Run 'atproto config reset' to fix.
```

## Environment Variable Overrides

Configuration values can be overridden by environment variables without modifying the config file. This is useful for:

- **CI/CD pipelines** - Different settings per environment
- **Automation scripts** - Temporary overrides
- **Testing** - Quick configuration changes

### Environment Variable Mapping

| Configuration Key | Environment Variable | Priority |
|-------------------|---------------------|----------|
| `pds_endpoint` | `ATP_PDS` | 1 (highest) |
| `output_format` | `ATP_OUTPUT_FORMAT` | 1 (highest) |
| `color_output` | `ATP_COLOR_OUTPUT` | 1 (highest) |
| `feed_limit` | `ATP_FEED_LIMIT` | 1 (highest) |
| `search_limit` | `ATP_SEARCH_LIMIT` | 1 (highest) |
| `debug` | `DEBUG` | 1 (highest) |

### Priority Order

1. **Environment Variable** (highest priority)
2. **Configuration File**
3. **Default Value** (lowest priority)

### Examples

**Temporary Override**:
```bash
# Use custom PDS for single command
ATP_PDS="https://test.bsky.social" atproto whoami

# Your config file is unchanged
atproto config get pds_endpoint
# Output: https://bsky.social
```

**Session Override**:
```bash
# Override for entire shell session
export ATP_FEED_LIMIT=100
export DEBUG=1

# All commands use these values
atproto feed  # Shows 100 posts
atproto search "bluesky"  # Debug output enabled
```

**Automation Script**:
```bash
#!/bin/bash
# automation.sh - Production automation script

export ATP_PDS="https://production.bsky.social"
export ATP_OUTPUT_FORMAT="json"
export ATP_COLOR_OUTPUT="never"

# Commands use overridden values
atproto whoami | jq '.did'
atproto feed | jq '.feed[0].post.record.text'
```

## Use Cases & Workflows

### For Regular Users

**Quick Setup**:
```bash
# Install and configure
atproto login
atproto config set feed_limit 30
atproto config set search_limit 15
```

**Daily Usage**:
```bash
atproto feed          # Uses configured limit (30)
atproto search "tech" # Uses configured limit (15)
```

### For Developers

**Development Setup**:
```bash
# Point to local PDS
atproto config set pds_endpoint http://localhost:2583
atproto config set debug true
```

**Testing**:
```bash
# Run tests with debug enabled
DEBUG=1 make test

# Test against production without changing config
ATP_PDS="https://bsky.social" atproto whoami
```

### For Automation/Bots

**Bot Configuration**:
```bash
# Machine-readable output for parsing
atproto config set output_format json
atproto config set color_output never
```

**CI/CD Pipeline**:
```bash
# .github/workflows/announce.yml
name: Announce Release

on:
  release:
    types: [published]

jobs:
  announce:
    runs-on: ubuntu-latest
    steps:
      - name: Post to Bluesky
        env:
          ATP_PDS: https://bsky.social
          ATP_OUTPUT_FORMAT: json
          BLUESKY_HANDLE: ${{ secrets.BLUESKY_HANDLE }}
          BLUESKY_PASSWORD: ${{ secrets.BLUESKY_PASSWORD }}
        run: |
          atproto login
          atproto post "🎉 New release: ${{ github.event.release.tag_name }}"
```

### For System Administrators

**System-Wide Configuration**:
```bash
# Configure for all users (in system config)
# /etc/environment
ATP_PDS=https://corporate-pds.company.com
ATP_OUTPUT_FORMAT=json
ATP_COLOR_OUTPUT=never
```

**Monitoring Scripts**:
```bash
# monitoring.sh
export ATP_PDS="https://monitor.bsky.social"
export ATP_FEED_LIMIT=100
export DEBUG=0

while true; do
    atproto feed | jq '.feed[].post.record.text' | grep -i "incident"
    sleep 300
done
```

## Troubleshooting

### Configuration File Not Found

**Problem**: Config commands fail with "file not found"

**Solution**:
```bash
# Initialize config manually
atproto config list  # This creates default config
```

### Invalid Configuration

**Problem**: Configuration values aren't being applied

**Solution**:
```bash
# Validate configuration
atproto config validate

# If invalid, reset to defaults
atproto config reset
```

### Environment Variables Not Working

**Problem**: Environment variables aren't overriding config

**Solution**:
```bash
# Verify environment variable is set
echo $ATP_PDS

# Make sure variable name matches documentation
# Correct: ATP_PDS
# Wrong:   ATP_PDS_ENDPOINT
```

### Permission Errors

**Problem**: Cannot write to config file

**Solution**:
```bash
# Check permissions
ls -la ~/.config/atproto/

# Fix permissions
chmod 644 ~/.config/atproto/config.json
chmod 755 ~/.config/atproto/
```

## Best Practices

### Security
- ✅ Config file stores preferences only (no credentials)
- ✅ Use environment variables for sensitive data in automation
- ✅ Keep config file backed up (`.backup` created automatically)

### Performance
- ✅ Use smaller limits (`feed_limit`, `search_limit`) for faster responses
- ✅ Increase limits only when needed for comprehensive views

### Automation
- ✅ Use `json` output format for scripts
- ✅ Set `color_output` to `never` for logs and pipes
- ✅ Override config with environment variables in CI/CD

### Development
- ✅ Enable `debug` mode during development
- ✅ Use separate config files per environment (via `XDG_CONFIG_HOME`)
- ✅ Test with `config validate` before deployment

## Advanced Topics

### Custom Config Location

Override the default config location:

```bash
# Use custom config directory
export XDG_CONFIG_HOME=/opt/atproto/config
atproto config list
# Config file: /opt/atproto/config/atproto/config.json
```

### Backup and Restore

**Backup**:
```bash
# Manual backup
cp ~/.config/atproto/config.json ~/atproto-config-backup.json

# Or use reset (creates automatic backup)
atproto config reset
# Backup created: /home/user/.config/atproto/config.json.backup
```

**Restore**:
```bash
# Restore from backup
cp ~/atproto-config-backup.json ~/.config/atproto/config.json
atproto config validate
```

### Multiple Configurations

Use different configs for different purposes:

```bash
# Personal account config
export XDG_CONFIG_HOME=~/.config/personal
atproto login
atproto config set feed_limit 50

# Work account config
export XDG_CONFIG_HOME=~/.config/work
atproto login
atproto config set feed_limit 20

# Bot account config
export XDG_CONFIG_HOME=~/.config/bot
atproto login
atproto config set output_format json
```

### Exporting Configuration

Export config as environment variables (for scripts):

```bash
# In your script
eval "$(atproto config export)"  # Sets ATP_* environment variables
echo $ATP_PDS
echo $ATP_FEED_LIMIT
```

**Note**: `config export` feature planned for future release.

## Configuration Schema

For developers and advanced users, the full JSON schema:

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "properties": {
    "pds_endpoint": {
      "type": "string",
      "format": "uri",
      "pattern": "^https?://",
      "description": "AT Protocol PDS endpoint URL"
    },
    "output_format": {
      "type": "string",
      "enum": ["text", "json"],
      "description": "Output format for commands"
    },
    "color_output": {
      "type": "string",
      "enum": ["auto", "always", "never"],
      "description": "Color output control"
    },
    "feed_limit": {
      "type": "integer",
      "minimum": 1,
      "maximum": 100,
      "description": "Default feed retrieval limit"
    },
    "search_limit": {
      "type": "integer",
      "minimum": 1,
      "maximum": 100,
      "description": "Default search result limit"
    },
    "debug": {
      "type": "boolean",
      "description": "Enable debug output"
    }
  },
  "required": [
    "pds_endpoint",
    "output_format",
    "color_output",
    "feed_limit",
    "search_limit",
    "debug"
  ]
}
```

## See Also

- [QUICKSTART.md](QUICKSTART.md) - Getting started with atproto
- [SECURITY.md](SECURITY.md) - Security best practices
- [AGENTS.md](AGENTS.md) - Automation and agent workflows
- [README.md](README.md) - Main documentation

---

*For issues or questions about configuration, please open an issue on [GitHub](https://github.com/p3nGu1nZz/atproto/issues).*
