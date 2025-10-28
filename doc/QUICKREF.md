# AT-bot Quick Reference - Encryption & Security

## Quick Commands

```bash
# Login with encrypted credential storage
at-bot login --save

# Login with debug mode (shows plaintext)
DEBUG=1 at-bot login --save

# Login without saving credentials
at-bot login

# Check current session
at-bot whoami

# Clear encrypted credentials
at-bot clear-credentials

# Logout (clears session)
at-bot logout
```

## Encryption Quick Facts

| Property | Value |
|----------|-------|
| **Algorithm** | AES-256-CBC |
| **Key Size** | 256 bits (32 bytes) |
| **Key Derivation** | PBKDF2 |
| **Salt** | Random per operation |
| **Implementation** | OpenSSL 3.x |
| **Key Location** | `~/.config/at-bot/.key` |
| **Credentials** | `~/.config/at-bot/credentials.json` |

## File Locations

```
~/.config/at-bot/
├── session.json        # Session tokens (600 permissions)
├── credentials.json    # Encrypted credentials (600 permissions)
└── .key               # Encryption key (600 permissions)
```

## Security Levels

### 🔴 Never Use
```bash
# Plaintext password in script
echo "my-password" > password.txt
```

### 🟠 Legacy (Deprecated)
```bash
# Base64 encoding (old format, still supported)
# Automatically migrated on next login
```

### 🟢 Current (Development)
```bash
# AES-256-CBC encryption
at-bot login --save
```

### 🟢 Recommended (Production)
```bash
# Environment variables
export BLUESKY_HANDLE="bot.bsky.social"
export BLUESKY_PASSWORD="app-password"
at-bot login
```

### 🔵 Future (Enterprise)
```bash
# System keyring (planned)
at-bot login --keyring
```

## Testing

```bash
# Run all tests
make test

# Run encryption tests only
./tests/test_encryption.sh

# Test with debug mode
DEBUG=1 at-bot login
```

## Troubleshooting

### "OpenSSL not found"
```bash
# Check OpenSSL installation
which openssl
openssl version

# Install OpenSSL (if needed)
# Debian/Ubuntu:
sudo apt-get install openssl

# macOS:
brew install openssl
```

### "Permission denied"
```bash
# Fix file permissions
chmod 600 ~/.config/at-bot/credentials.json
chmod 600 ~/.config/at-bot/.key
chmod 600 ~/.config/at-bot/session.json
```

### "Decryption failed"
```bash
# Remove corrupted files and re-login
at-bot clear-credentials
at-bot logout
at-bot login --save
```

## Environment Variables

```bash
# Non-interactive login
export BLUESKY_HANDLE="user.bsky.social"
export BLUESKY_PASSWORD="app-password"
at-bot login

# Debug mode
export DEBUG=1
at-bot login

# Custom PDS endpoint
export ATP_PDS="https://custom.pds.example"
at-bot login
```

## Security Best Practices

### ✅ DO
- Use app passwords (not main password)
- Use on personal, secure machines
- Clear credentials when done
- Keep .key file secure
- Use DEBUG mode only in private
- Update OpenSSL regularly

### ❌ DON'T
- Commit credentials.json or .key to git
- Share .key file
- Use on shared/public machines
- Store production credentials this way
- Copy files between machines
- Expose encrypted files publicly

## Git Safety

```bash
# Already in .gitignore:
.config/at-bot/session.json
.config/at-bot/credentials.json
.config/at-bot/.key

# Double-check before committing
git status
```

## Quick Migration

### From Base64 to AES-256-CBC

```bash
# Old format still works (shows warning)
at-bot login

# To upgrade to new encryption:
at-bot clear-credentials  # Remove old format
at-bot login --save       # Save with new encryption
```

### From Encrypted to Environment Variables

```bash
# 1. Get your credentials from encrypted storage
DEBUG=1 at-bot whoami  # Shows your handle

# 2. Set environment variables
export BLUESKY_HANDLE="your-handle.bsky.social"
export BLUESKY_PASSWORD="your-app-password"

# 3. Clear encrypted storage
at-bot clear-credentials

# 4. Login with env vars
at-bot login
```

## Development Workflow

```bash
# 1. Login once with credential save
at-bot login --save

# 2. Develop and test freely
at-bot post "Test post 1"
at-bot post "Test post 2"
at-bot feed

# 3. Clear when done
at-bot clear-credentials
at-bot logout
```

## Production Deployment

```bash
# Use environment variables or secret manager
export BLUESKY_HANDLE="bot.bsky.social"
export BLUESKY_PASSWORD="app-password"

# In your deployment script
at-bot login
at-bot post "Deployment successful!"

# Don't use --save in production
```

## Documentation

- [doc/ENCRYPTION.md](doc/ENCRYPTION.md) - Complete encryption guide
- [doc/SECURITY.md](doc/SECURITY.md) - Security best practices
- [doc/TESTING.md](doc/TESTING.md) - Testing procedures
- [doc/DEBUG_MODE.md](doc/DEBUG_MODE.md) - Debug mode usage
- [README.md](README.md) - Main documentation

## Support

- **GitHub Issues**: Report bugs and request features
- **Security Issues**: See [doc/SECURITY.md](doc/SECURITY.md) for responsible disclosure
- **Contributing**: See [doc/CONTRIBUTING.md](doc/CONTRIBUTING.md)

---

**Quick Reference Version:** 1.0  
**AT-bot Version:** 0.1.0  
**Last Updated:** October 28, 2025
