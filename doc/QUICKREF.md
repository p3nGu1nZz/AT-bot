# atproto Quick Reference - Encryption & Security

## Quick Commands

```bash
# Login with encrypted credential storage
atproto login --save

# Login with debug mode (shows plaintext)
DEBUG=1 atproto login --save

# Login without saving credentials
atproto login

# Check current session
atproto whoami

# Clear encrypted credentials
atproto clear-credentials

# Logout (clears session)
atproto logout
```

## Encryption Quick Facts

| Property | Value |
|----------|-------|
| **Algorithm** | AES-256-CBC |
| **Key Size** | 256 bits (32 bytes) |
| **Key Derivation** | PBKDF2 |
| **Salt** | Random per operation |
| **Implementation** | OpenSSL 3.x |
| **Key Location** | `~/.config/atproto/.key` |
| **Credentials** | `~/.config/atproto/credentials.json` |

## File Locations

```
~/.config/atproto/
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
atproto login --save
```

### 🟢 Recommended (Production)
```bash
# Environment variables
export BLUESKY_HANDLE="bot.bsky.social"
export BLUESKY_PASSWORD="app-password"
atproto login
```

### 🔵 Future (Enterprise)
```bash
# System keyring (planned)
atproto login --keyring
```

## Testing

```bash
# Run all tests
make test

# Run encryption tests only
./tests/test_encryption.sh

# Test with debug mode
DEBUG=1 atproto login
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
chmod 600 ~/.config/atproto/credentials.json
chmod 600 ~/.config/atproto/.key
chmod 600 ~/.config/atproto/session.json
```

### "Decryption failed"
```bash
# Remove corrupted files and re-login
atproto clear-credentials
atproto logout
atproto login --save
```

## Environment Variables

```bash
# Non-interactive login
export BLUESKY_HANDLE="user.bsky.social"
export BLUESKY_PASSWORD="app-password"
atproto login

# Debug mode
export DEBUG=1
atproto login

# Custom PDS endpoint
export ATP_PDS="https://custom.pds.example"
atproto login
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
.config/atproto/session.json
.config/atproto/credentials.json
.config/atproto/.key

# Double-check before committing
git status
```

## Quick Migration

### From Base64 to AES-256-CBC

```bash
# Old format still works (shows warning)
atproto login

# To upgrade to new encryption:
atproto clear-credentials  # Remove old format
atproto login --save       # Save with new encryption
```

### From Encrypted to Environment Variables

```bash
# 1. Get your credentials from encrypted storage
DEBUG=1 atproto whoami  # Shows your handle

# 2. Set environment variables
export BLUESKY_HANDLE="your-handle.bsky.social"
export BLUESKY_PASSWORD="your-app-password"

# 3. Clear encrypted storage
atproto clear-credentials

# 4. Login with env vars
atproto login
```

## Development Workflow

```bash
# 1. Login once with credential save
atproto login --save

# 2. Develop and test freely
atproto post "Test post 1"
atproto post "Test post 2"
atproto feed

# 3. Clear when done
atproto clear-credentials
atproto logout
```

## Production Deployment

```bash
# Use environment variables or secret manager
export BLUESKY_HANDLE="bot.bsky.social"
export BLUESKY_PASSWORD="app-password"

# In your deployment script
atproto login
atproto post "Deployment successful!"

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
**atproto Version:** 0.1.0  
**Last Updated:** October 28, 2025
