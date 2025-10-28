# AT-bot Testing Guide

This guide explains the complete testing approach for AT-bot, including automated unit tests, interactive manual testing, and end-to-end integration tests.

## Quick Start

### Unit Tests (Automated)

Run the automated unit test suite:

```bash
make test-unit
```

Or with options:

```bash
# Run with verbose output
bash scripts/test-unit.sh --verbose

# List all available tests
bash scripts/test-unit.sh --list

# Run specific test (e.g., tests matching 'cli')
bash scripts/test-unit.sh test_cli
```

**Test Suite Summary:**
- **12 unit tests** covering all major features
- **~5 seconds** to run complete suite
- **91% success rate** (manual_test.sh requires interactive input)
- Tests: Authentication, Content, Social, Configuration, Integration

### Interactive Manual Testing

Use the interactive test helper:

```bash
./tests/manual_test.sh
```

Or via make:

```bash
make test-manual
```

This script will:
1. Prompt you to login (if not already logged in)
2. Offer to save your credentials securely (optional)
3. Provide an interactive menu to test all features

## Test Runner Reference (`scripts/test-unit.sh`)

The `test-unit.sh` script provides a comprehensive unit test runner with multiple options and features.

### Usage

```bash
scripts/test-unit.sh [options] [test_pattern]
```

### Options

| Option | Description |
|--------|-------------|
| `-v, --verbose` | Show detailed test output and logs |
| `-q, --quiet` | Suppress output, only show results |
| `-c, --coverage` | Show test coverage information |
| `-l, --list` | List available tests without running |
| `-f, --failed-only` | Only show failed tests in final report |
| `-h, --help` | Show help message and usage |

### Examples

```bash
# Run all tests
scripts/test-unit.sh

# List available tests
scripts/test-unit.sh --list

# Run tests matching pattern
scripts/test-unit.sh test_cli

# Verbose output with details
scripts/test-unit.sh --verbose

# Show coverage information
scripts/test-unit.sh --coverage

# Only show failures
scripts/test-unit.sh --failed-only
```

### Test Categories

The test suite is organized into five categories:

**Authentication Tests** (3 tests, 539 lines)
- `test_cli_basic.sh` - Basic CLI functionality (help, version, commands)
- `test_encryption.sh` - Encryption and credential storage
- `test_profile.sh` - User profile retrieval and management

**Content Management Tests** (2 tests, 401 lines)
- `test_post_feed.sh` - Post creation and feed operations
- `test_media_upload.sh` - Media upload and attachment handling

**Social Operations Tests** (3 tests, 338 lines)
- `test_follow.sh` - Follow and relationship management
- `test_followers.sh` - Follower/following list operations
- `test_search.sh` - Post and user search functionality

**Configuration Tests** (2 tests, 285 lines)
- `test_config.sh` - Configuration management
- `test_library.sh` - Library function testing

**Integration Tests** (3 tests, 1,368 lines)
- `atp_test.sh` - Comprehensive AT Protocol integration
- `manual_test.sh` - Manual testing utilities (interactive)
- `debug_demo.sh` - Debug mode demonstrations

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | All tests passed |
| 1 | Some tests failed |
| 2 | Invalid arguments |

### Environment Variables

| Variable | Effect |
|----------|--------|
| `AT_BOT_TEST_VERBOSE` | Enable verbose output |
| `AT_BOT_TEST_TIMEOUT` | Test timeout in seconds (default: 60) |
| `AT_BOT_DEBUG` | Enable debug mode for tests |

### CI/CD Integration

The test runner is designed for CI/CD pipelines:

```bash
#!/bin/bash
# Example GitHub Actions workflow

# Run unit tests
bash scripts/test-unit.sh --quiet
exit_code=$?

if [ $exit_code -eq 0 ]; then
    echo "✓ All tests passed"
else
    echo "✗ Tests failed"
    bash scripts/test-unit.sh --verbose  # Show details
    exit 1
fi
```

## Makefile Test Commands

You can run all tests using make commands:

| Command | Description |
|---------|-------------|
| `make test` | Run all tests (unit + e2e) |
| `make test-unit` | Run unit test suite (12 tests) |
| `make test-manual` | Run interactive manual test suite |
| `make test-e2e` | Run end-to-end integration tests |
| `make help` | Show all available make targets |

### Examples

```bash
# Run unit tests (fastest, ~5 seconds)
make test-unit

# Run manual tests (interactive)
make test-manual

# Run integration tests
make test-e2e

# Run all tests
make test
```

### With Environment Variables

```bash
# Run tests with verbose output
AT_BOT_TEST_VERBOSE=1 make test-unit

# Run tests with custom timeout (60 seconds default)
AT_BOT_TEST_TIMEOUT=30 make test-unit

# Run with debug mode enabled
AT_BOT_DEBUG=1 make test-unit
```

## Complete Test Suite

### Running All Tests

```bash
make test
```

This runs:
1. `tests/run_tests.sh` - Basic test runner
2. Includes all 12 unit tests

### Running Unit Tests (Recommended)

```bash
make test-unit
```

Or directly:

```bash
bash scripts/test-unit.sh
```

### Running Manual Tests

```bash
make test-manual
```

For interactive testing with full feature exploration.

### Running End-to-End Tests

```bash
make test-e2e
```

For comprehensive AT Protocol integration testing.

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
