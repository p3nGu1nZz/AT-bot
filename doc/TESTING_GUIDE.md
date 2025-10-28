# AT-bot Testing Guide

This guide explains the two complementary testing approaches available in AT-bot.

## Quick Comparison

| Feature | Manual Test | Automated E2E Test |
|---------|-------------|-------------------|
| **Best For** | Learning, debugging, exploration | CI/CD, regression, quick validation |
| **Interactivity** | Menu-driven, user control | Automated, credential saving |
| **Speed** | Slower (user-paced) | Faster (sequential) |
| **Output** | Detailed, formatted | Summary-focused |
| **Authentication** | Interactive login each time | Save credentials for automation |
| **Suitable For** | Local development | Continuous integration |

## Manual Test Suite (`manual_test.sh`)

### Purpose
Interactive, menu-driven testing interface for exploring all AT-bot features.

### When to Use
- 🔍 Learning the API
- 🐛 Debugging specific features
- 👀 Visual exploration
- 🧪 Testing individual operations

### How to Run

```bash
# Option 1: Direct
bash tests/manual_test.sh

# Option 2: Via Make
make test-manual

# Option 3: From installed location
at-bot-manual-test  # If installed via make install
```

### Features
- ✅ Multi-level menu navigation (8 categories, 28+ tests)
- ✅ Authentication onboarding with session validation
- ✅ Colored output with emojis
- ✅ Per-test execution control
- ✅ Detailed results with parsed output
- ✅ Back navigation between menus

### Categories
1. **🔐 Authentication & Session** - User verification, session info, logout
2. **📝 Content Management** - Post creation, feed reading
3. **👥 Social Interactions** - Follow, unfollow, block, mute operations
4. **🔍 Search & Discovery** - Post and user search
5. **📊 User Profiles** - View own/other profiles and followers
6. **⚙️ System & Configuration** - Help, environment, config viewing
7. **🧪 Diagnostics** - System checks, dependency verification
8. **🚪 Exit** - Return to previous menu

### Example Session

```
┌─ Main Menu ──────────┐
│ [1] Authentication   │
│ [2] Content          │
│ ...                  │
│ [0] Exit             │
└──────────────────────┘

> Enter choice: 1

┌─ Authentication Tests ─┐
│ [1] Verify Current User│
│ [2] Validate Session   │
│ [3] View Session Info  │
│ [0] Back               │
└───────────────────────┘

> Enter choice: 1

✓ User information retrieved:
  Handle: at-bot.bsky.social
  DID: did:plc:...

Press Enter to continue...
```

## Automated E2E Test Suite (`atp_test.sh`)

### Purpose
Non-interactive, automated end-to-end testing for regression testing and CI/CD pipelines.

### When to Use
- 🔄 Continuous integration
- ✓ Regression testing
- 📦 Release validation
- 🤖 Automated workflows
- ⚡ Quick full-feature check

### How to Run

```bash
# Option 1: Direct
bash tests/atp_test.sh

# Option 2: Via Make
make test-e2e

# Option 3: With options
bash tests/atp_test.sh --verbose  # Verbose output
bash tests/atp_test.sh --help     # Show help
```

### Features
- ✅ Automatic authentication
- ✅ Credential saving and loading
- ✅ Sequential test execution
- ✅ Non-interactive after first setup
- ✅ Exit codes for CI/CD integration
- ✅ Detailed error reporting
- ✅ Test summary statistics

### Credential Management

**First Run (Interactive)**
```bash
$ bash tests/atp_test.sh

Handle (e.g., user.bsky.social): at-bot.bsky.social
App Password: ••••••••••

Save credentials for next test run? (y/n): y

✓ Credentials saved for next test run
```

**Subsequent Runs (Automated)**
```bash
$ bash tests/atp_test.sh

ℹ Loaded saved credentials for automated testing
ℹ Authentication successful

Running tests...
```

**In CI/CD (Fully Automated)**
```bash
# First time setup (one-time)
bash tests/atp_test.sh  # Prompts for credentials, saves them

# Then in CI/CD config, simply run:
bash tests/atp_test.sh  # Uses saved credentials, fully automated
```

### Test Coverage

The E2E suite tests:
1. **Authentication** - User verification via whoami
2. **Content** - Feed reading (timeline)
3. **Profiles** - Own profile viewing
4. **Search** - Post searching
5. **Configuration** - Config management
6. **Diagnostics** - System checks and dependency verification

### Output Example

```
╔═══════════════════════════════════════════════════════════╗
║  AT-bot Automated Integration Tests                   ║
╚═══════════════════════════════════════════════════════════╝

────────────────────────────────────────────────────────────
│ 🔐 Authentication Tests                               │
────────────────────────────────────────────────────────────
  ▶ Verify current user...
  ✓ Verify current user
        Logged in as:
          Handle: at-bot.bsky.social
          DID: did:plc:...

────────────────────────────────────────────────────────────
│ 📝 Content Management Tests                           │
────────────────────────────────────────────────────────────
  ▶ Read timeline (10 posts)...
  ✓ Read timeline (10 posts)

...

╔═══════════════════════════════════════════════════════════╗
║  Test Summary                                          ║
╚═══════════════════════════════════════════════════════════╝

  Total Tests:    6
  ✓ Passed:       6
  ✗ Failed:       0
  ⊘ Skipped:      0

✓ All tests passed!
```

### Exit Codes
- `0` - All tests passed
- `1` - One or more tests failed
- `1` - Authentication failed

## Using with CI/CD

### GitHub Actions Example

```yaml
name: AT-bot Integration Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup AT-bot
        run: make install PREFIX=$HOME/.local
      
      - name: Run unit tests
        run: make test
      
      - name: Run E2E tests
        run: bash tests/atp_test.sh
        env:
          BLUESKY_HANDLE: ${{ secrets.BLUESKY_HANDLE }}
          BLUESKY_PASSWORD: ${{ secrets.BLUESKY_PASSWORD }}
```

### Local Pre-commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit

echo "Running E2E tests..."
if ! bash tests/atp_test.sh; then
    echo "Tests failed, commit aborted"
    exit 1
fi
```

## Credential Storage

### Locations
- **Session Token**: `~/.config/at-bot/session.json` (mode 600)
- **Test Credentials**: `~/.config/at-bot/.test_credentials` (mode 600)

### Security
- Both files stored with `chmod 600` (owner read/write only)
- Never commit credentials to version control
- `.test_credentials` should be in `.gitignore`
- Environment variables used during login only

### Adding to .gitignore

```bash
echo ".test_credentials" >> .gitignore
echo "session.json" >> .gitignore
```

## Troubleshooting

### Manual Test Exits Without Prompt
✅ **Fixed** in v0.3.0 - Removed `set -e` that caused premature exits

### Automated Test Shows "User" Instead of Handle
✅ **Fixed** in v0.3.0 - Updated handle parsing in authentication check

### Credentials Not Being Saved
- Check that `~/.config/at-bot/` directory exists
- Verify write permissions: `ls -la ~/.config/at-bot/`
- Ensure you answered "y" to the save prompt

### Authentication Fails in E2E Tests
1. Verify credentials are correct: `at-bot login`
2. Clear saved credentials: `rm ~/.config/at-bot/.test_credentials`
3. Run tests again and re-enter credentials

### Tests Pass Locally but Fail in CI/CD
- Verify `BLUESKY_HANDLE` and `BLUESKY_PASSWORD` secrets are set
- Ensure test account has no rate-limit restrictions
- Check that AT Protocol server is accessible from CI environment

## Development Tips

### Running Specific Test
Edit `tests/manual_test.sh` or `tests/atp_test.sh` and modify the main menu:

```bash
# manual_test.sh - go straight to auth tests
handle_auth_menu

# atp_test.sh - run only auth tests
test_auth
print_summary
```

### Adding New Tests

**For Manual Suite**:
1. Add function: `test_new_feature() { ... }`
2. Add menu item in `show_*_menu()`
3. Add case statement in `handle_*_menu()`

**For E2E Suite**:
1. Add function: `test_*() { ... }`
2. Call from appropriate category test
3. Update test counter if needed

### Verbose Output

```bash
# Manual test - check exact output
bash tests/manual_test.sh 2>&1 | tee test.log

# E2E test - verbose mode
bash tests/atp_test.sh --verbose
```

## See Also
- `README.md` - General AT-bot documentation
- `doc/TESTING.md` - Detailed testing procedures
- `STYLE.md` - Code standards for tests
- `bin/at-bot` - Main CLI entry point

---

**Last Updated**: October 28, 2025  
**AT-bot Version**: v0.3.0+  
**Status**: Testing framework complete and operational
