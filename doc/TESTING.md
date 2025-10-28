# AT-bot Testing Guide

This guide explains how to test AT-bot securely without exposing your credentials.

## Quick Start

### Manual Testing

Use the interactive test helper:

```bash
./tests/manual_test.sh
```

This script will:
1. Prompt you to login (if not already logged in)
2. Offer to save your credentials securely (optional)
3. Provide an interactive menu to test all features

### Secure Credential Storage

AT-bot supports **optional** secure credential storage for testing and automation purposes.

#### How It Works

When you login, AT-bot will ask:

```
Save credentials securely for testing/automation? (y/n):
```

If you choose **yes**:
- Your credentials are saved to `~/.config/at-bot/credentials.json`
- Password is **encrypted** using AES-256-CBC encryption
- Encryption key is stored in `~/.config/at-bot/.key` with 600 permissions
- Both files are readable only by you (mode 600)
- On next login, credentials are automatically decrypted and loaded

#### Security Considerations

**Encryption Details:**
- Algorithm: AES-256-CBC (Advanced Encryption Standard)
- Key derivation: PBKDF2 with salt
- Random salt used for each encryption
- 64-character random encryption key
- OpenSSL implementation

**Important Notes:**
- Credentials are **encrypted**, not just encoded
- Encryption key is machine-specific
- Only use this feature on secure, personal machines
- Never commit `credentials.json` or `.key` to version control
- For production use, prefer environment variables or proper secret management

#### Migration from Old Base64 Format

If you have credentials saved with the old base64 encoding:
- They will still work (backward compatibility)
- You'll see a warning to upgrade
- Simply logout and login again to upgrade to AES-256 encryption

#### Clearing Saved Credentials

```bash
at-bot clear-credentials
```

Or manually delete:
```bash
rm ~/.config/at-bot/credentials.json
```

## Testing Features

### 1. Login and Session Management

```bash
# Interactive login (will prompt for credentials)
at-bot login

# Check current user
at-bot whoami

# Logout
at-bot logout
```

### 2. Debug Mode (Show Plaintext Passwords)

For debugging authentication issues, you can enable debug mode:

```bash
# Enable debug output (shows plaintext passwords)
DEBUG=1 at-bot login
```

**Debug mode will show:**
- Password length when entered
- Password in plaintext
- Password in base64 encoding
- Credential loading operations
- API request details

**⚠️ Security Warning:** Only use DEBUG=1 in secure, private environments. Debug output will print passwords to the terminal.

### 3. Creating Posts

```bash
# Create a simple post
at-bot post "Hello from AT-bot! 🤖"

# Create a post with special characters (use quotes)
at-bot post "Testing #ATProtocol with @handle.bsky.social"
```

### 4. Reading Your Feed

```bash
# Read default (10 posts)
at-bot feed

# Read specific number of posts
at-bot feed 20
```

## Automated Testing

### Using Environment Variables

For CI/CD or automated testing without interactive prompts:

```bash
export BLUESKY_HANDLE="your.handle.bsky.social"
export BLUESKY_PASSWORD="your-app-password"

at-bot login
at-bot post "Automated test post"
at-bot feed
```

### Using Saved Credentials

If you've saved credentials:

```bash
# Credentials are automatically loaded
at-bot login

# Or use environment variable to skip saving prompt
BLUESKY_HANDLE="your.handle" at-bot login
```

## Test Suite

Run the automated test suite:

```bash
make test
```

This runs:
- `test_cli_basic.sh` - Basic CLI functionality tests
- `test_library.sh` - Library function tests
- `test_post_feed.sh` - Post and feed functionality tests

## Best Practices

### For Development Testing

1. **Use saved credentials** for quick iteration:
   ```bash
   at-bot login  # Save when prompted
   # Now you can test repeatedly without re-entering password
   ```

2. **Use the manual test helper**:
   ```bash
   ./tests/manual_test.sh
   ```

3. **Clear credentials** when done:
   ```bash
   at-bot clear-credentials
   ```

### For Production Use

1. **Use environment variables**:
   ```bash
   export BLUESKY_HANDLE="bot.bsky.social"
   export BLUESKY_PASSWORD="xxxx-xxxx-xxxx-xxxx"
   ```

2. **Never save credentials** on shared systems

3. **Use app passwords**, not your main password

4. **Consider proper secret management** for production deployments

## Creating App Passwords

For security, always use Bluesky app passwords instead of your main password:

1. Go to Bluesky Settings
2. Navigate to Privacy and Security
3. Select "App Passwords"
4. Create a new app password
5. Use this password with AT-bot

## Troubleshooting

### Credentials Not Loading

If saved credentials aren't loading:

```bash
# Check if file exists and has correct permissions
ls -la ~/.config/at-bot/credentials.json

# Should show: -rw------- (600)
```

### Session Expired

If your session expires:

```bash
# Logout and login again
at-bot logout
at-bot login
```

### Clear Everything

To start fresh:

```bash
rm -rf ~/.config/at-bot/
at-bot login
```

## Security Notes

⚠️ **Important Security Information**

### Credential Storage

- `credentials.json` contains your **encrypted** password
- `.key` file contains the encryption key (64 random characters)
- Both files are protected with `600` permissions (owner only)
- Encryption uses **AES-256-CBC** with PBKDF2 key derivation
- Random salt ensures different ciphertext for same password

### Best Practices

**Development/Testing:**
- ✓ Save credentials on personal, secure machines
- ✓ Use app passwords, not main account passwords
- ✓ Clear credentials when done: `at-bot clear-credentials`

**Production:**
- ✓ Use environment variables for credentials
- ✓ Use proper secret management systems (Vault, AWS Secrets Manager, etc.)
- ✓ Never commit credentials or keys to version control
- ✓ Consider system keyring integration (future enhancement)

### Security Comparison

| Method | Security Level | Use Case |
|--------|---------------|----------|
| Environment Variables | Medium | CI/CD, automated scripts |
| Encrypted File (AES-256) | Good | Development/testing |
| System Keyring | Better | Desktop applications |
| Secret Management Service | Best | Production deployments |

### What AT-bot Does

✓ **Encrypts** passwords with AES-256-CBC  
✓ **Never stores** plaintext passwords  
✓ **Uses** random salts for encryption  
✓ **Sets** strict file permissions (600)  
✓ **Supports** migration from old format  
✓ **Requires** OpenSSL for encryption

## File Locations

- **Session**: `~/.config/at-bot/session.json` (access tokens)
- **Credentials**: `~/.config/at-bot/credentials.json` (saved login, optional)

Both files are automatically created with `600` permissions (owner read/write only).

---

**Need Help?**

- Run `at-bot help` for command reference
- Check [README.md](../README.md) for general documentation
- Review [SECURITY.md](../doc/SECURITY.md) for security guidelines
