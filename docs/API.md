# AT-bot API Reference

Complete API documentation for AT-bot including AT Protocol library functions, CLI commands, and MCP (Model Context Protocol) tools.

**Table of Contents:**
- [AT Protocol Library API](#at-protocol-library-api)
- [CLI Commands](#cli-commands)
- [MCP Tools](#mcp-tools)

---

## AT Protocol Library API

The AT Protocol library (`lib/atproto.sh`) provides core functionality for interacting with Bluesky's AT Protocol. All functions are designed to be composable and support both interactive and programmatic usage.

### Authentication Functions

#### `atproto_login`

Authenticate a user with Bluesky using AT Protocol credentials.

**Signature:**
```bash
atproto_login [handle] [password]
```

**Arguments:**
- `$1` (optional) - Bluesky handle or email (e.g., `user.bsky.social`)
- `$2` (optional) - App password or account password

**Returns:**
- `0` - Success, session created and stored
- `1` - Authentication failed

**Environment Variables:**
- `BLUESKY_HANDLE` - Default handle for non-interactive use
- `BLUESKY_PASSWORD` - Default password for non-interactive use
- `ATP_PDS` - AT Protocol server endpoint (default: `https://bsky.social`)

**Session Storage:**
- Creates `~/.config/at-bot/session.json` with mode 600
- Stores encrypted access token and refresh token
- Session can be refreshed automatically

**Example:**
```bash
# Interactive login
at-bot login

# Non-interactive with environment variables
export BLUESKY_HANDLE="user.bsky.social"
export BLUESKY_PASSWORD="app_password"
at-bot login

# Direct parameters
at-bot login user.bsky.social app_password
```

**Security Notes:**
- Passwords are never stored permanently
- Session tokens are encrypted using AES-256-CBC
- Use app passwords, not account passwords, for production
- Debug mode (`DEBUG=1`) shows plaintext for development only

---

#### `atproto_logout`

Logout and clear the current session.

**Signature:**
```bash
atproto_logout
```

**Returns:**
- `0` - Success, session cleared
- `1` - Logout failed

**Files Modified:**
- Removes `~/.config/at-bot/session.json`

**Example:**
```bash
at-bot logout
```

---

#### `atproto_whoami`

Display information about the currently authenticated user.

**Signature:**
```bash
atproto_whoami
```

**Returns:**
- `0` - Success, user info displayed
- `1` - Not logged in or fetch failed

**Output Format:**

Text (default):
```
Logged in as:
  Handle: user.bsky.social
  DID: did:plc:xxxxxxxxxxxxx
```

JSON (with `--format json`):
```json
{
  "handle": "user.bsky.social",
  "did": "did:plc:xxxxxxxxxxxxx"
}
```

**Example:**
```bash
at-bot whoami
# Output: Handle: user.bsky.social, DID: did:plc:xxxxxxxxxxxxx
```

---

#### `refresh_session`

Automatically refresh the session using the stored refresh token.

**Signature:**
```bash
refresh_session
```

**Returns:**
- `0` - Session refreshed successfully
- `1` - Refresh failed

**Details:**
- Called automatically when session is older than 1.5 hours
- Extends session lifetime without requiring re-authentication
- Updates `~/.config/at-bot/session.json`

**Example:**
```bash
refresh_session && echo "Session refreshed"
```

---

#### `validate_session`

Validate that the current session is active and functional.

**Signature:**
```bash
validate_session
```

**Returns:**
- `0` - Session is valid
- `1` - Session invalid or expired

**Example:**
```bash
if validate_session; then
    echo "Session is valid"
else
    echo "Please login"
fi
```

---

### Content Management Functions

#### `atproto_post`

Create a new post on Bluesky.

**Signature:**
```bash
atproto_post <text> [--image <file>] [--reply-to <uri>]
```

**Arguments:**
- `$1` (required) - Post text content
- `--image <file>` (optional) - Image file path to attach
- `--reply-to <uri>` (optional) - Post URI to reply to (creates thread)

**Returns:**
- `0` - Post created successfully
- `1` - Post creation failed

**Output:**
Returns post URI: `at://did:plc:xxxxxxxxxxxxx/app.bsky.feed.post/xxxxxxxxxx`

**Limits:**
- Maximum 300 characters for post text
- Supports UTF-8 including emojis
- Multiple media attachments (up to API limit)

**Example:**
```bash
# Simple post
at-bot post "Hello Bluesky!"

# Post with image
at-bot post "Check this photo!" --image photo.jpg

# Reply to post
at-bot post "Great post!" --reply-to "at://did:plc:xxxxxxxxxxxxx/app.bsky.feed.post/xxxxxxxxxx"
```

---

#### `atproto_reply`

Reply to an existing post.

**Signature:**
```bash
atproto_reply <parent_uri> <text> [--image <file>]
```

**Arguments:**
- `$1` (required) - Parent post URI to reply to
- `$2` (required) - Reply text content
- `--image <file>` (optional) - Image to attach

**Returns:**
- `0` - Reply created successfully
- `1` - Reply failed

**Example:**
```bash
at-bot reply "at://did:plc:xxxxxxxxxxxxx/app.bsky.feed.post/xxxxxxxxxx" "Thanks for sharing!"
```

---

#### `atproto_upload_blob`

Upload a binary blob (image/video) to AT Protocol for use in posts.

**Signature:**
```bash
atproto_upload_blob <file_path>
```

**Arguments:**
- `$1` (required) - File path to upload

**Returns:**
- `0` - Upload successful, returns blob reference JSON
- `1` - Upload failed

**Output:**
Returns JSON blob reference:
```json
{
  "blob": {
    "cid": "bafyrexxxxxxxxx",
    "mimeType": "image/jpeg",
    "size": 102400
  }
}
```

**Supported Media Types:**
- Images: JPEG, PNG, GIF, WebP
- Videos: MP4 (future version)

**Size Limits:**
- Images: up to 1 MB
- Videos: up to 50 MB (future)

**Example:**
```bash
at-bot post "Check this!" --image photo.jpg
```

---

### Feed and Discovery Functions

#### `atproto_feed`

Read your Bluesky timeline.

**Signature:**
```bash
atproto_feed [limit] [--format text|json]
```

**Arguments:**
- `$1` (optional) - Number of posts to retrieve (default: 10, max: 100)
- `--format` (optional) - Output format (text or json)

**Returns:**
- `0` - Timeline retrieved successfully
- `1` - Fetch failed

**Output Format:**

Text (default):
```
Feed retrieved successfully!

     1    First post text here...
     2    Second post text here...
```

JSON:
```json
{
  "feed": [
    {"post": {...}, "reply": {...}},
    ...
  ]
}
```

**Example:**
```bash
# Default (10 posts)
at-bot feed

# Custom limit (20 posts)
at-bot feed 20

# JSON output
at-bot feed 10 --format json
```

---

#### `atproto_search`

Search for posts on Bluesky.

**Signature:**
```bash
atproto_search <query> [limit] [--format text|json]
```

**Arguments:**
- `$1` (required) - Search query
- `$2` (optional) - Maximum results (default: 10, max: 100)
- `--format` (optional) - Output format

**Returns:**
- `0` - Search completed successfully
- `1` - Search failed

**Output Format:**

Text (default):
```
Search results for: 'query'

Found 5 posts:

     1    Matching post 1...
     2    Matching post 2...
```

**Search Features:**
- Full-text search across post content
- Hashtag search with `#hashtag`
- Author search with `from:handle`
- Boolean operators (AND, OR, NOT)

**Example:**
```bash
# Simple search
at-bot search "bluesky"

# Search with limit
at-bot search "at-protocol" 20

# JSON output
at-bot search "automation" 10 --format json
```

---

### Profile Functions

#### `atproto_show_profile`

Display profile information for a user.

**Signature:**
```bash
atproto_show_profile [handle_or_did] [--format text|json]
```

**Arguments:**
- `$1` (optional) - User handle or DID (defaults to current user)
- `--format` (optional) - Output format

**Returns:**
- `0` - Profile retrieved successfully
- `1` - Profile fetch failed

**Output Format:**

Text (default):
```
Profile Information
===================

Name:        User Display Name
Handle:      @user.bsky.social
Bio:         User biography

Stats:
  Posts:     N/A
  Followers: N/A
  Following: N/A
```

JSON:
```json
{
  "did": "did:plc:xxxxxxxxxxxxx",
  "handle": "user.bsky.social",
  "displayName": "User Name",
  "description": "User bio"
}
```

**Example:**
```bash
# Current user profile
at-bot profile

# Another user's profile
at-bot profile p3ngu1nzz.bsky.social

# JSON format
at-bot profile --format json
```

---

#### `atproto_get_profile`

Get profile information in JSON format (library function).

**Signature:**
```bash
atproto_get_profile [handle_or_did]
```

**Returns:**
- `0` - Profile retrieved successfully
- `1` - Profile fetch failed

**Output:**
Raw JSON profile object

---

#### `atproto_update_profile`

Update the current user's profile information.

**Signature:**
```bash
atproto_update_profile [--name <name>] [--bio <bio>] \
                        [--avatar <file>] [--banner <file>]
```

**Arguments:**
- `--name` (optional) - Display name
- `--bio` (optional) - Profile biography
- `--avatar` (optional) - Avatar image file
- `--banner` (optional) - Banner image file

**Returns:**
- `0` - Profile updated successfully
- `1` - Update failed

**Example:**
```bash
at-bot profile-edit --name "New Name" --bio "New bio"
at-bot profile-edit --avatar avatar.jpg --banner banner.jpg
```

---

### Social Graph Functions

#### `atproto_follow`

Follow a user on Bluesky.

**Signature:**
```bash
atproto_follow <handle_or_did>
```

**Arguments:**
- `$1` (required) - User handle or DID to follow

**Returns:**
- `0` - User followed successfully
- `1` - Follow failed

**API Used:**
- Endpoint: `/xrpc/com.atproto.repo.createRecord`
- Record Type: `app.bsky.graph.follow`

**Example:**
```bash
at-bot follow user.bsky.social
at-bot follow did:plc:xxxxxxxxxxxxx
```

---

#### `atproto_unfollow`

Unfollow a user on Bluesky.

**Signature:**
```bash
atproto_unfollow <handle_or_did>
```

**Arguments:**
- `$1` (required) - User handle or DID to unfollow

**Returns:**
- `0` - User unfollowed successfully
- `1` - Unfollow failed

**Example:**
```bash
at-bot unfollow user.bsky.social
```

---

#### `atproto_followers`

View followers of a user.

**Signature:**
```bash
atproto_followers [handle] [limit]
```

**Arguments:**
- `$1` (optional) - User handle (defaults to current user)
- `$2` (optional) - Limit (default: 50, max: 100)

**Returns:**
- `0` - Followers retrieved successfully
- `1` - Fetch failed

**Output:**
List of followers with profiles

---

#### `atproto_following`

View who a user follows.

**Signature:**
```bash
atproto_following [handle] [limit]
```

**Arguments:**
- `$1` (optional) - User handle (defaults to current user)
- `$2` (optional) - Limit (default: 50, max: 100)

**Returns:**
- `0` - Following list retrieved successfully
- `1` - Fetch failed

---

### Engagement Functions

#### `atproto_like`

Like a post.

**Signature:**
```bash
atproto_like <post_uri>
```

**Arguments:**
- `$1` (required) - Post URI to like

**Returns:**
- `0` - Post liked successfully
- `1` - Like failed

**Example:**
```bash
at-bot like "at://did:plc:xxxxxxxxxxxxx/app.bsky.feed.post/xxxxxxxxxx"
```

---

#### `atproto_repost`

Repost a post.

**Signature:**
```bash
atproto_repost <post_uri>
```

**Arguments:**
- `$1` (required) - Post URI to repost

**Returns:**
- `0` - Post reposted successfully
- `1` - Repost failed

**Example:**
```bash
at-bot repost "at://did:plc:xxxxxxxxxxxxx/app.bsky.feed.post/xxxxxxxxxx"
```

---

### Block and Mute Functions

#### `atproto_block_user`

Block a user.

**Signature:**
```bash
atproto_block_user <handle_or_did>
```

**Arguments:**
- `$1` (required) - User handle or DID to block

**Returns:**
- `0` - User blocked successfully
- `1` - Block failed

---

#### `atproto_unblock_user`

Unblock a user.

**Signature:**
```bash
atproto_unblock_user <handle_or_did>
```

**Arguments:**
- `$1` (required) - User handle or DID to unblock

**Returns:**
- `0` - User unblocked successfully
- `1` - Unblock failed

---

#### `atproto_mute_user`

Mute a user (hide their posts).

**Signature:**
```bash
atproto_mute_user <handle_or_did>
```

**Arguments:**
- `$1` (required) - User handle or DID to mute

**Returns:**
- `0` - User muted successfully
- `1` - Mute failed

---

#### `atproto_unmute_user`

Unmute a user.

**Signature:**
```bash
atproto_unmute_user <handle_or_did>
```

**Arguments:**
- `$1` (required) - User handle or DID to unmute

**Returns:**
- `0` - User unmuted successfully
- `1` - Unmute failed

---

### Utility Functions

#### `api_request`

Make a direct HTTP request to the AT Protocol API.

**Signature:**
```bash
api_request <method> <endpoint> <data> [access_token]
```

**Arguments:**
- `$1` - HTTP method (GET, POST, etc.)
- `$2` - API endpoint path (e.g., `/xrpc/com.atproto.server.getSession`)
- `$3` - Request data/body (JSON string or empty for GET)
- `$4` - Access token (optional for public endpoints)

**Returns:**
- `0` - Request successful, outputs response
- `1` - Request failed

**Example:**
```bash
api_request GET "/xrpc/app.bsky.feed.getTimeline?limit=10" "" "$token"
api_request POST "/xrpc/com.atproto.repo.createRecord" "$record_json" "$token"
```

---

#### `json_get_field`

Extract a field value from JSON.

**Signature:**
```bash
json_get_field <json_string> <field_name>
```

**Arguments:**
- `$1` - JSON string or data
- `$2` - Field name to extract

**Returns:**
- Field value (stdout)
- Empty string if field not found

**Example:**
```bash
response='{"handle":"user.bsky.social","did":"did:plc:xxx"}'
handle=$(json_get_field "$response" "handle")
echo "$handle"  # Output: user.bsky.social
```

---

#### `get_access_token`

Retrieve the current access token from the session.

**Signature:**
```bash
get_access_token
```

**Returns:**
- `0` - Token retrieved successfully, outputs token
- `1` - No valid session

**Features:**
- Automatically refreshes expired tokens
- Checks session age (refreshes if older than 1.5 hours)

---

#### `get_session_did`

Get the DID (Decentralized Identifier) of the current user.

**Signature:**
```bash
get_session_did
```

**Returns:**
- `0` - DID retrieved, outputs DID value
- `1` - No valid session

**Example:**
```bash
did=$(get_session_did)
echo "Current user DID: $did"
```

---

---

## CLI Commands

The AT-bot command-line interface provides user-friendly access to all AT Protocol functionality.

### Authentication Commands

#### `at-bot login`

Authenticate with Bluesky interactively or non-interactively.

**Usage:**
```bash
at-bot login [handle] [password]
```

**Examples:**
```bash
# Interactive
at-bot login

# Non-interactive with environment variables
export BLUESKY_HANDLE="user.bsky.social"
export BLUESKY_PASSWORD="app_password"
at-bot login

# Direct arguments
at-bot login user.bsky.social app_password
```

---

#### `at-bot logout`

Logout and clear the current session.

**Usage:**
```bash
at-bot logout
```

---

#### `at-bot whoami`

Show information about the current user.

**Usage:**
```bash
at-bot whoami
```

---

#### `at-bot refresh`

Manually refresh the session token.

**Usage:**
```bash
at-bot refresh
```

---

### Content Commands

#### `at-bot post <text>`

Create a new post.

**Usage:**
```bash
at-bot post "Post content"
at-bot post "Post with image" --image photo.jpg
```

---

#### `at-bot reply <uri> <text>`

Reply to a post.

**Usage:**
```bash
at-bot reply "at://..." "Reply text"
```

---

#### `at-bot like <uri>`

Like a post.

**Usage:**
```bash
at-bot like "at://..."
```

---

#### `at-bot repost <uri>`

Repost a post.

**Usage:**
```bash
at-bot repost "at://..."
```

---

### Feed Commands

#### `at-bot feed [limit]`

Read your timeline.

**Usage:**
```bash
at-bot feed           # 10 posts (default)
at-bot feed 20        # 20 posts
```

---

#### `at-bot search <query> [limit]`

Search for posts.

**Usage:**
```bash
at-bot search "bluesky"
at-bot search "at-protocol" 20
```

---

### Profile Commands

#### `at-bot profile [handle]`

View a user's profile.

**Usage:**
```bash
at-bot profile                    # Current user
at-bot profile user.bsky.social   # Specific user
```

---

#### `at-bot profile-edit [options]`

Edit current user's profile.

**Usage:**
```bash
at-bot profile-edit --name "New Name" --bio "New bio"
at-bot profile-edit --avatar avatar.jpg --banner banner.jpg
```

---

### Social Commands

#### `at-bot follow <handle>`

Follow a user.

**Usage:**
```bash
at-bot follow user.bsky.social
```

---

#### `at-bot unfollow <handle>`

Unfollow a user.

**Usage:**
```bash
at-bot unfollow user.bsky.social
```

---

#### `at-bot followers [handle] [limit]`

View followers.

**Usage:**
```bash
at-bot followers                  # Your followers
at-bot followers user.bsky.social # Another user's followers
at-bot followers user.bsky.social 100 # With custom limit
```

---

#### `at-bot following [handle] [limit]`

View who a user follows.

**Usage:**
```bash
at-bot following                  # Your following list
at-bot following user.bsky.social # Another user's following
```

---

### Configuration Commands

#### `at-bot config list`

Show all configuration values.

**Usage:**
```bash
at-bot config list
```

---

#### `at-bot config get <key>`

Get a specific configuration value.

**Usage:**
```bash
at-bot config get feed_limit
```

---

#### `at-bot config set <key> <value>`

Set a configuration value.

**Usage:**
```bash
at-bot config set feed_limit 50
at-bot config set output_format json
```

---

#### `at-bot config reset`

Reset configuration to defaults.

**Usage:**
```bash
at-bot config reset
```

---

#### `at-bot config validate`

Validate the configuration file.

**Usage:**
```bash
at-bot config validate
```

---

### Utility Commands

#### `at-bot clear-credentials`

Clear saved credentials.

**Usage:**
```bash
at-bot clear-credentials
```

---

#### `at-bot help`

Show help message.

**Usage:**
```bash
at-bot help
at-bot -h
```

---

#### `at-bot version`

Show version information.

**Usage:**
```bash
at-bot -v
```

---

---

## MCP Tools

Model Context Protocol (MCP) tools for integration with AI agents like Claude, ChatGPT, and other MCP-compatible systems.

### Authentication Tools

#### `auth_login`

Authenticate with AT Protocol.

**Input Schema:**
```json
{
  "handle": "string (required)",
  "password": "string (required)"
}
```

**Output:**
```json
{
  "success": boolean,
  "message": "string",
  "handle": "string"
}
```

**Example:**
```json
{
  "handle": "user.bsky.social",
  "password": "app_password"
}
```

---

#### `auth_logout`

Logout and clear session.

**Input Schema:** (empty)

**Output:**
```json
{
  "success": boolean,
  "message": "string"
}
```

---

#### `auth_whoami`

Get current user information.

**Input Schema:** (empty)

**Output:**
```json
{
  "handle": "string",
  "did": "string",
  "status": "authenticated"
}
```

---

#### `auth_is_authenticated`

Check if currently authenticated.

**Input Schema:** (empty)

**Output:**
```json
{
  "authenticated": boolean,
  "handle": "string|null"
}
```

---

### Content Tools

#### `post_create`

Create a new post.

**Input Schema:**
```json
{
  "text": "string (required, max 300 chars)",
  "reply_to": "string (optional, post URI)",
  "attachments": "array (optional, media URIs)"
}
```

**Output:**
```json
{
  "success": boolean,
  "uri": "string",
  "cid": "string"
}
```

---

#### `post_reply`

Reply to a post.

**Input Schema:**
```json
{
  "parent_uri": "string (required)",
  "text": "string (required)",
  "attachments": "array (optional)"
}
```

**Output:**
```json
{
  "success": boolean,
  "uri": "string"
}
```

---

#### `post_like`

Like a post.

**Input Schema:**
```json
{
  "post_uri": "string (required)"
}
```

**Output:**
```json
{
  "success": boolean,
  "message": "string"
}
```

---

#### `post_repost`

Repost a post.

**Input Schema:**
```json
{
  "post_uri": "string (required)"
}
```

**Output:**
```json
{
  "success": boolean,
  "message": "string"
}
```

---

#### `post_delete`

Delete a post.

**Input Schema:**
```json
{
  "post_uri": "string (required)"
}
```

**Output:**
```json
{
  "success": boolean,
  "message": "string"
}
```

---

### Feed Tools

#### `feed_read`

Read user's timeline.

**Input Schema:**
```json
{
  "limit": "number (optional, default: 10, max: 100)",
  "cursor": "string (optional, for pagination)"
}
```

**Output:**
```json
{
  "posts": "array of posts",
  "cursor": "string (for pagination)"
}
```

---

#### `feed_search`

Search for posts.

**Input Schema:**
```json
{
  "query": "string (required)",
  "limit": "number (optional, default: 10)",
  "sort": "string (optional, 'hot' or 'recent')"
}
```

**Output:**
```json
{
  "results": "array of posts",
  "count": "number"
}
```

---

#### `feed_timeline`

Get timeline (alias for feed_read).

**Input Schema:**
```json
{
  "limit": "number (optional)",
  "cursor": "string (optional)"
}
```

---

#### `feed_notifications`

Get notifications.

**Input Schema:**
```json
{
  "limit": "number (optional, default: 10)"
}
```

**Output:**
```json
{
  "notifications": "array of notification objects"
}
```

---

### Profile Tools

#### `profile_get`

Get user profile information.

**Input Schema:**
```json
{
  "actor": "string (optional, handle or DID)"
}
```

**Output:**
```json
{
  "handle": "string",
  "did": "string",
  "displayName": "string",
  "description": "string",
  "avatar": "string (image URL)"
}
```

---

#### `profile_follow`

Follow a user.

**Input Schema:**
```json
{
  "target": "string (required, handle or DID)"
}
```

**Output:**
```json
{
  "success": boolean,
  "message": "string"
}
```

---

#### `profile_unfollow`

Unfollow a user.

**Input Schema:**
```json
{
  "target": "string (required, handle or DID)"
}
```

**Output:**
```json
{
  "success": boolean,
  "message": "string"
}
```

---

#### `profile_block`

Block a user.

**Input Schema:**
```json
{
  "target": "string (required, handle or DID)"
}
```

**Output:**
```json
{
  "success": boolean,
  "message": "string"
}
```

---

#### `profile_unblock`

Unblock a user.

**Input Schema:**
```json
{
  "target": "string (required, handle or DID)"
}
```

**Output:**
```json
{
  "success": boolean,
  "message": "string"
}
```

---

### Search Tools

#### `search_posts`

Search for posts.

**Input Schema:**
```json
{
  "query": "string (required)",
  "limit": "number (optional, default: 10)"
}
```

**Output:**
```json
{
  "results": "array of posts",
  "count": "number"
}
```

---

#### `search_users`

Search for users.

**Input Schema:**
```json
{
  "query": "string (required)",
  "limit": "number (optional, default: 10)"
}
```

**Output:**
```json
{
  "results": "array of user profiles",
  "count": "number"
}
```

---

### Engagement Tools

#### `engagement_like`

Like a post (alias for post_like).

**Input Schema:**
```json
{
  "post_uri": "string (required)"
}
```

---

#### `engagement_repost`

Repost a post (alias for post_repost).

**Input Schema:**
```json
{
  "post_uri": "string (required)"
}
```

---

### Social Tools

#### `social_followers`

Get user's followers.

**Input Schema:**
```json
{
  "actor": "string (optional, handle or DID)",
  "limit": "number (optional, default: 50)"
}
```

**Output:**
```json
{
  "followers": "array of profiles",
  "count": "number"
}
```

---

#### `social_following`

Get user's following list.

**Input Schema:**
```json
{
  "actor": "string (optional, handle or DID)",
  "limit": "number (optional, default: 50)"
}
```

**Output:**
```json
{
  "following": "array of profiles",
  "count": "number"
}
```

---

#### `social_mutuals`

Get mutual follows.

**Input Schema:**
```json
{
  "actor": "string (optional, handle or DID)"
}
```

**Output:**
```json
{
  "mutuals": "array of profiles"
}
```

---

### Media Tools

#### `media_upload`

Upload media (image/video).

**Input Schema:**
```json
{
  "file": "string (required, file path or URL)",
  "type": "string (optional, 'image' or 'video')"
}
```

**Output:**
```json
{
  "success": boolean,
  "blob": {
    "cid": "string",
    "mimeType": "string",
    "size": "number"
  }
}
```

---

#### `media_get_info`

Get information about media.

**Input Schema:**
```json
{
  "cid": "string (required)"
}
```

**Output:**
```json
{
  "cid": "string",
  "mimeType": "string",
  "size": "number",
  "url": "string"
}
```

---

---

## Common Response Codes

### HTTP Status Codes (from AT Protocol API)

| Code | Meaning | Example |
|------|---------|---------|
| 200 | Success | Post created, user followed |
| 400 | Bad request | Invalid input, missing required field |
| 401 | Unauthorized | Invalid credentials, expired token |
| 403 | Forbidden | Cannot perform action (blocked user, etc.) |
| 404 | Not found | User or post doesn't exist |
| 429 | Rate limited | Too many requests, retry later |
| 500 | Server error | AT Protocol server error |

### Shell Script Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | General error |
| 2 | Invalid usage/arguments |
| 127 | Command not found |

---

## Error Handling

All functions follow consistent error handling patterns:

```bash
# Check return code
if atproto_login "user.bsky.social" "password"; then
    echo "Login successful"
else
    echo "Login failed"
fi

# Capture error message
if ! output=$(atproto_post "text" 2>&1); then
    echo "Error: $output"
fi
```

---

## Rate Limiting

The AT Protocol API enforces rate limits:

- **Default:** 1500 requests per 5 minutes
- **Search:** 30 queries per minute
- **Auth:** 15 login attempts per 5 minutes

AT-bot handles rate limiting transparently through automatic exponential backoff.

---

## Security Considerations

1. **Credentials:** Always use app passwords, never account passwords
2. **Session Storage:** Sessions stored with mode 600 (owner read/write only)
3. **Encryption:** Access tokens encrypted using AES-256-CBC
4. **Environment Variables:** `DEBUG=1` shows plaintext for development only
5. **Audit Logging:** Enable debug mode to log all API calls

---

## Examples and Recipes

### Automated Daily Post

```bash
#!/bin/bash
source /usr/local/lib/at-bot/atproto.sh

# Set up environment
export BLUESKY_HANDLE="bot.bsky.social"
export BLUESKY_PASSWORD="app_password"

# Login if not already authenticated
at-bot login

# Get current time
NOW=$(date '+%Y-%m-%d %H:%M:%S')

# Create daily post
at-bot post "Daily update: $NOW - All systems operational! #automation"
```

### Post with Image

```bash
#!/bin/bash
at-bot post "Check this photo!" --image ~/photos/screenshot.jpg
```

### Search and Engage

```bash
#!/bin/bash
# Search for posts
results=$(at-bot search "#bluesky" 5)

# Like matching posts (example - actual parsing depends on output format)
# This is pseudocode - real implementation would parse URIs
```

### Multi-Account Management

```bash
#!/bin/bash
# Function to post with different accounts
post_as() {
    local handle="$1"
    local password="$2"
    local text="$3"
    
    export BLUESKY_HANDLE="$handle"
    export BLUESKY_PASSWORD="$password"
    
    at-bot login
    at-bot post "$text"
    at-bot logout
}

# Post with multiple accounts
post_as "account1.bsky.social" "password1" "Message 1"
post_as "account2.bsky.social" "password2" "Message 2"
```

---

## Version History

### v0.1.0 (October 2025) - Current

**AT Protocol API Functions:**
- Authentication: login, logout, whoami, session management
- Content: post, reply, upload media
- Feed: read timeline, search
- Profile: view, update profiles
- Social: follow, unfollow, block, mute
- Engagement: like, repost

**CLI Commands:**
- All AT Protocol functions exposed as CLI commands
- Configuration management
- Session management
- Help and documentation

**MCP Tools:**
- 31 tools for AI agent integration
- Full support for auth, content, feed, profile, search, engagement, social, media

---

## Getting Help

- **Documentation:** `at-bot help`
- **Configuration:** See [CONFIGURATION.md](CONFIGURATION.md)
- **Encryption:** See [ENCRYPTION.md](ENCRYPTION.md)
- **Debugging:** Enable with `DEBUG=1 at-bot [command]`
- **Issues:** https://github.com/p3nGu1nZz/AT-bot/issues

---

*Last Updated: October 28, 2025*
*API Version: 0.1.0*
