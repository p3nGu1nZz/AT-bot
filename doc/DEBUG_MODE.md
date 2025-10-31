# atproto Debug Mode Quick Reference

## Enable Debug Mode

```bash
DEBUG=1 atproto [command]
```

## What Debug Mode Shows

### During Login
```bash
DEBUG=1 atproto login
```

**Output includes:**
- `[DEBUG] Handle entered: your.handle.bsky.social`
- `[DEBUG] Password entered (length: 19)`
- `[DEBUG] Password (plaintext): your-actual-password`
- `[DEBUG] Attempting login for: your.handle.bsky.social`
- `[DEBUG] Sending authentication request to https://bsky.social`

### When Saving Credentials
```bash
DEBUG=1 atproto login
# ... enter credentials ...
# Choose 'y' to save
```

**Output includes:**
- `[DEBUG] Saving credentials for: your.handle.bsky.social`
- `[DEBUG] Password (plaintext): your-actual-password`
- `[DEBUG] Password encrypted with AES-256-CBC`
- `[DEBUG] Encrypted data: U2FsdGVkX1/jBQdTc9arcQQz...`

### When Loading Saved Credentials
```bash
DEBUG=1 atproto login
# If credentials already saved
```

**Output includes:**
- `[DEBUG] Loaded credentials for: your.handle.bsky.social`
- `[DEBUG] Encryption method: aes-256-cbc`
- `[DEBUG] Encrypted data: U2FsdGVkX1/jBQdTc9arcQQz...`
- `[DEBUG] Password (plaintext): your-actual-password`

## Use Cases

### 1. Verify Credentials are Saved Correctly
```bash
# First login and save
atproto login
# ... enter credentials, choose 'y' to save ...

# Verify they load correctly
DEBUG=1 atproto logout
DEBUG=1 atproto login
# Should see: "Using saved credentials for ..."
# Debug output shows the loaded password
```

### 2. Troubleshoot Login Issues
```bash
DEBUG=1 atproto login
# See exactly what's being sent to the API
```

### 3. Verify Password Encoding
```bash
DEBUG=1 atproto login
# See the AES-256-CBC encryption process
```

## Security Warning ⚠️

**NEVER use DEBUG=1 in:**
- Shared terminals
- Screen recordings
- Screen sharing sessions
- Public demonstrations
- CI/CD logs (unless secured)
- Any environment where others can see your screen

**Debug output will display your password in plaintext!**

## Disable Debug Mode

Simply don't set DEBUG=1:

```bash
# Normal mode (no debug output)
atproto login
```

Or explicitly disable:

```bash
DEBUG=0 atproto login
```

## Example Debug Session

```bash
# Terminal session showing debug output
$ DEBUG=1 atproto login
[DEBUG] No credentials file found
Bluesky handle (e.g., user.bsky.social): myhandle.bsky.social
[DEBUG] Handle entered: myhandle.bsky.social
App password (will not be stored): 
[DEBUG] Password entered (length: 19)
[DEBUG] Password (plaintext): abcd-efgh-ijkl-mnop
Save credentials securely for testing/automation? (y/n): y
[DEBUG] Attempting login for: myhandle.bsky.social
[DEBUG] Sending authentication request to https://bsky.social
Authenticating...
[DEBUG] Saving credentials for: myhandle.bsky.social
[DEBUG] Password (plaintext): abcd-efgh-ijkl-mnop
[DEBUG] Password encrypted with AES-256-CBC
[DEBUG] Encrypted data: U2FsdGVkX1/jBQdTc9arcQQz3rF0dULp...
✓ Credentials saved with AES-256-CBC encryption to /home/user/.config/atproto/credentials.json
✓ Successfully logged in as: myhandle.bsky.social
```

## Tips

1. **Use in a private terminal window**
2. **Clear your terminal history after debugging:**
   ```bash
   history -c
   ```
3. **Or use a temporary session:**
   ```bash
   bash --norc --noprofile
   DEBUG=1 atproto login
   exit
   ```

## Related Commands

- `atproto help` - Show all commands
- `atproto clear-credentials` - Remove saved credentials
- `cat ~/.config/atproto/credentials.json` - View saved credentials file
- `DEBUG=1 atproto whoami` - Debug current session

---

**Remember:** Debug mode is for development only. Never use in production or public environments!
