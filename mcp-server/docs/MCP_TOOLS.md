# atproto MCP Tools Reference

This document provides detailed specifications for all MCP tools exposed by the atproto MCP server. Each tool includes its schema, parameters, return values, and example usage.

## Authentication Tools

### `auth_login`

Authenticate a user with Bluesky using AT Protocol.

**Schema:**
```json
{
  "name": "auth_login",
  "description": "Authenticate with Bluesky using handle and password",
  "inputSchema": {
    "type": "object",
    "properties": {
      "handle": {
        "type": "string",
        "description": "Bluesky handle or email address"
      },
      "password": {
        "type": "string",
        "description": "App password (not main account password)"
      }
    },
    "required": ["handle", "password"]
  }
}
```

**Returns:**
```json
{
  "success": true,
  "did": "did:plc:...",
  "handle": "user.bsky.social",
  "message": "Successfully authenticated"
}
```

**Error Cases:**
- `401`: Invalid credentials
- `429`: Rate limited
- `500`: Server error

**Example Usage:**
```
Agent: Call auth_login with handle="alice.bsky.social" and password="app-password-123"
Response: {success: true, did: "did:plc:...", handle: "alice.bsky.social"}
```

**Security Notes:**
- Use app passwords, not main account password
- Credentials never stored in logs
- Session token cached with restrictive permissions (600)

---

### `auth_logout`

Clear the current session and remove stored credentials.

**Schema:**
```json
{
  "name": "auth_logout",
  "description": "Clear the current session",
  "inputSchema": {
    "type": "object",
    "properties": {}
  }
}
```

**Returns:**
```json
{
  "success": true,
  "message": "Session cleared"
}
```

**Example Usage:**
```
Agent: Call auth_logout
Response: {success: true, message: "Session cleared"}
```

---

### `auth_whoami`

Get information about the currently authenticated user.

**Schema:**
```json
{
  "name": "auth_whoami",
  "description": "Get current user information",
  "inputSchema": {
    "type": "object",
    "properties": {}
  }
}
```

**Returns:**
```json
{
  "did": "did:plc:...",
  "handle": "alice.bsky.social",
  "displayName": "Alice",
  "description": "Developer and AT Protocol enthusiast",
  "avatar": "https://..."
}
```

**Error Cases:**
- `401`: Not authenticated

**Example Usage:**
```
Agent: Call auth_whoami
Response: {did: "did:plc:...", handle: "alice.bsky.social", displayName: "Alice"}
```

---

### `auth_is_authenticated`

Check if a valid session exists without making API calls.

**Schema:**
```json
{
  "name": "auth_is_authenticated",
  "description": "Check if currently authenticated",
  "inputSchema": {
    "type": "object",
    "properties": {}
  }
}
```

**Returns:**
```json
{
  "authenticated": true,
  "handle": "alice.bsky.social",
  "expiresAt": "2025-10-29T10:30:00Z"
}
```

**Example Usage:**
```
Agent: Call auth_is_authenticated
Response: {authenticated: true, handle: "alice.bsky.social", expiresAt: "2025-10-29T10:30:00Z"}
```

---

## Engagement Tools

### `post_create`

Create a new post on Bluesky.

**Status:** ✅ Implemented

**Schema:**
```json
{
  "name": "post_create",
  "description": "Create a new post",
  "inputSchema": {
    "type": "object",
    "properties": {
      "text": {
        "type": "string",
        "description": "Post content (300 character limit)"
      },
      "image": {
        "type": "string",
        "description": "Optional image file path or URL"
      }
    },
    "required": ["text"]
  }
}
```

**Returns:**
```json
{
  "success": true,
  "uri": "at://did:plc:.../app.bsky.feed.post/...",
  "cid": "bafy...",
  "timestamp": "2025-10-28T10:30:00Z"
}
```

**Error Cases:**
- `400`: Invalid text or attachments
- `401`: Not authenticated
- `429`: Rate limited
- `413`: Text too long

**Example Usage:**
```
Agent: Call post_create with text="Hello from atproto MCP! 🤖"
Response: {success: true, uri: "at://...", cid: "bafy..."}
```

**Constraints:**
- Maximum 300 characters
- Must be authenticated

---

### `post_reply`

Reply to an existing post.

**Status:** ✅ Implemented

**Schema:**
```json
{
  "name": "post_reply",
  "description": "Reply to a post",
  "inputSchema": {
    "type": "object",
    "properties": {
      "text": {
        "type": "string",
        "description": "Reply content"
      },
      "replyTo": {
        "type": "string",
        "description": "AT-URI of post to reply to (e.g., at://did:plc:.../app.bsky.feed.post/...)"
      }
    },
    "required": ["text", "replyTo"]
  }
}
```

**Returns:**
```json
{
  "success": true,
  "uri": "at://...",
  "cid": "bafy...",
  "rootUri": "at://...",
  "parentUri": "at://..."
}
```

**Example Usage:**
```
Agent: Call post_reply with text="Great post!" and replyTo="at://did:plc:..."
Response: {success: true, uri: "at://...", cid: "bafy..."}
```

---

### `post_like`

Like an existing post.

**Status:** ✅ Implemented

**Schema:**
```json
{
  "name": "post_like",
  "description": "Like a post",
  "inputSchema": {
    "type": "object",
    "properties": {
      "postUri": {
        "type": "string",
        "description": "AT-URI of post to like (e.g., at://did:plc:.../app.bsky.feed.post/...)"
      }
    },
    "required": ["postUri"]
  }
}
```

**Returns:**
```json
{
  "success": true,
  "message": "Post liked successfully"
}
```

**Example Usage:**
```
Agent: Call post_like with postUri="at://did:plc:..."
Response: {success: true, message: "Post liked successfully"}
```

---

### `post_repost`

Repost (rebleet) an existing post.

**Status:** ✅ Implemented

**Schema:**
```json
{
  "name": "post_repost",
  "description": "Repost a post",
  "inputSchema": {
    "type": "object",
    "properties": {
      "postUri": {
        "type": "string",
        "description": "AT-URI of post to repost (e.g., at://did:plc:.../app.bsky.feed.post/...)"
      }
    },
    "required": ["postUri"]
  }
}
```

**Returns:**
```json
{
  "success": true,
  "message": "Post reposted successfully"
}
```

**Example Usage:**
```
Agent: Call post_repost with postUri="at://did:plc:..."
Response: {success: true, message: "Post reposted successfully"}
```

---

### `post_delete`

Delete an existing post.

**Status:** ✅ Implemented

**Schema:**
```json
{
  "name": "post_delete",
  "description": "Delete a post",
  "inputSchema": {
    "type": "object",
    "properties": {
      "postUri": {
        "type": "string",
        "description": "AT-URI of post to delete (e.g., at://did:plc:.../app.bsky.feed.post/...)"
      }
    },
    "required": ["postUri"]
  }
}
```

**Returns:**
```json
{
  "success": true,
  "message": "Post deleted successfully"
}
```

**Example Usage:**
```
Agent: Call post_delete with postUri="at://did:plc:..."
Response: {success: true, message: "Post deleted successfully"}
```

---

## Social Tools

### `follow_user`

Follow a user on Bluesky.

**Status:** ✅ Implemented

**Schema:**
```json
{
  "name": "follow_user",
  "description": "Follow a user",
  "inputSchema": {
    "type": "object",
    "properties": {
      "handle": {
        "type": "string",
        "description": "User handle (e.g., user.bsky.social)"
      }
    },
    "required": ["handle"]
  }
}
```

**Returns:**
```json
{
  "success": true,
  "message": "Successfully followed: user.bsky.social"
}
```

**Example Usage:**
```
Agent: Call follow_user with handle="alice.bsky.social"
Response: {success: true, message: "Successfully followed: alice.bsky.social"}
```

---

### `unfollow_user`

Unfollow a user on Bluesky.

**Status:** ✅ Implemented

**Schema:**
```json
{
  "name": "unfollow_user",
  "description": "Unfollow a user",
  "inputSchema": {
    "type": "object",
    "properties": {
      "handle": {
        "type": "string",
        "description": "User handle (e.g., user.bsky.social)"
      }
    },
    "required": ["handle"]
  }
}
```

**Returns:**
```json
{
  "success": true,
  "message": "Successfully unfollowed: user.bsky.social"
}
```

**Example Usage:**
```
Agent: Call unfollow_user with handle="alice.bsky.social"
Response: {success: true, message: "Successfully unfollowed: alice.bsky.social"}
```

---

### `get_followers`

Get a user's followers list.

**Status:** ✅ Implemented

**Schema:**
```json
{
  "name": "get_followers",
  "description": "Get user's followers list",
  "inputSchema": {
    "type": "object",
    "properties": {
      "handle": {
        "type": "string",
        "description": "User handle (defaults to current user if not provided)"
      },
      "limit": {
        "type": "number",
        "description": "Maximum followers to return (default: 50)"
      }
    }
  }
}
```

**Returns:**
```json
{
  "success": true,
  "message": "Followers for alice.bsky.social:\n\n1. bob.bsky.social\n2. charlie.bsky.social\n..."
}
```

**Example Usage:**
```
Agent: Call get_followers with handle="alice.bsky.social", limit=20
Response: {success: true, message: "Followers for alice.bsky.social:\n\n1. bob.bsky.social\n..."}
```

---

### `get_following`

Get a user's following list.

**Status:** ✅ Implemented

**Schema:**
```json
{
  "name": "get_following",
  "description": "Get user's following list",
  "inputSchema": {
    "type": "object",
    "properties": {
      "handle": {
        "type": "string",
        "description": "User handle (defaults to current user if not provided)"
      },
      "limit": {
        "type": "number",
        "description": "Maximum follows to return (default: 50)"
      }
    }
  }
}
```

**Returns:**
```json
{
  "success": true,
  "message": "Following for alice.bsky.social:\n\n1. bob.bsky.social\n2. charlie.bsky.social\n..."
}
```

**Example Usage:**
```
Agent: Call get_following with handle="alice.bsky.social", limit=20
Response: {success: true, message: "Following for alice.bsky.social:\n\n1. bob.bsky.social\n..."}
```

---

### `block_user`

Block a user.

**Status:** ✅ Implemented

**Schema:**
```json
{
  "name": "block_user",
  "description": "Block a user",
  "inputSchema": {
    "type": "object",
    "properties": {
      "handle": {
        "type": "string",
        "description": "User handle to block"
      }
    },
    "required": ["handle"]
  }
}
```

**Returns:**
```json
{
  "success": true,
  "message": "User blocked successfully"
}
```

**Example Usage:**
```
Agent: Call block_user with handle="spam-bot.bsky.social"
Response: {success: true, message: "User blocked successfully"}
```

---

### `unblock_user`

Unblock a user.

**Status:** ✅ Implemented

**Schema:**
```json
{
  "name": "unblock_user",
  "description": "Unblock a user",
  "inputSchema": {
    "type": "object",
    "properties": {
      "handle": {
        "type": "string",
        "description": "User handle to unblock"
      }
    },
    "required": ["handle"]
  }
}
```

**Returns:**
```json
{
  "success": true,
  "message": "User unblocked successfully"
}
```

**Example Usage:**
```
Agent: Call unblock_user with handle="spam-bot.bsky.social"
Response: {success: true, message: "User unblocked successfully"}
```

---

## Search & Discovery Tools

### `search_posts`

Search for posts on Bluesky matching a query.

**Status:** ✅ Implemented

**Schema:**
```json
{
  "name": "search_posts",
  "description": "Search for posts matching a query",
  "inputSchema": {
    "type": "object",
    "properties": {
      "query": {
        "type": "string",
        "description": "Search query string"
      },
      "limit": {
        "type": "number",
        "description": "Maximum results to return (default: 10)"
      }
    },
    "required": ["query"]
  }
}
```

**Returns:**
```json
{
  "success": true,
  "message": "Search results for: bluesky\n\nFound 10 posts:\n\n1. First post...\n2. Second post..."
}
```

**Example Usage:**
```
Agent: Call search_posts with query="bluesky", limit=20
Response: {success: true, message: "Search results..."}
```

---

### `read_feed`

Read the authenticated user's home feed.

**Status:** ✅ Implemented

**Schema:**
```json
{
  "name": "read_feed",
  "description": "Read user's home feed",
  "inputSchema": {
    "type": "object",
    "properties": {
      "limit": {
        "type": "number",
        "description": "Number of posts to return (default: 10)"
      }
    }
  }
}
```

**Returns:**
```json
{
  "success": true,
  "message": "Recent feed posts:\n\n1. Post 1 by alice.bsky.social...\n2. Post 2 by bob.bsky.social..."
}
```

**Example Usage:**
```
Agent: Call read_feed with limit=20
Response: {success: true, message: "Recent feed posts:\n\n1. Post 1..."}
```

---

### `search_users`

Search for users on Bluesky.

**Status:** ✅ Implemented

**Schema:**
```json
{
  "name": "search_users",
  "description": "Search for users",
  "inputSchema": {
    "type": "object",
    "properties": {
      "query": {
        "type": "string",
        "description": "Search query (handle or display name)"
      },
      "limit": {
        "type": "number",
        "description": "Maximum results to return (default: 10)"
      }
    },
    "required": ["query"]
  }
}
```

**Returns:**
```json
{
  "success": true,
  "message": "Search results for users: alice\n\n1. alice.bsky.social - Alice Developer\n2. alice-bot.bsky.social - Alice Bot\n..."
}
```

**Example Usage:**
```
Agent: Call search_users with query="alice", limit=20
Response: {success: true, message: "Search results for users: alice\n\n1. alice.bsky.social..."}
```

---

## Media Tools

### `post_with_image`

Create a post with a single image attachment.

**Status:** ✅ Implemented

**Schema:**
```json
{
  "name": "post_with_image",
  "description": "Create a post with an image",
  "inputSchema": {
    "type": "object",
    "properties": {
      "text": {
        "type": "string",
        "description": "Post text content"
      },
      "imagePath": {
        "type": "string",
        "description": "Path to image file (PNG, JPEG, etc.)"
      }
    },
    "required": ["text", "imagePath"]
  }
}
```

**Returns:**
```json
{
  "success": true,
  "uri": "at://did:plc:.../app.bsky.feed.post/...",
  "message": "Post created with image successfully"
}
```

**Example Usage:**
```
Agent: Call post_with_image with text="Check this out! 📸" and imagePath="/path/to/image.png"
Response: {success: true, uri: "at://...", message: "Post created with image successfully"}
```

---

### `post_with_gallery`

Create a post with multiple images (gallery).

**Status:** ✅ Implemented

**Schema:**
```json
{
  "name": "post_with_gallery",
  "description": "Create a post with multiple images",
  "inputSchema": {
    "type": "object",
    "properties": {
      "text": {
        "type": "string",
        "description": "Post text content"
      },
      "imagePaths": {
        "type": "array",
        "description": "Paths to image files (max 4 images)",
        "items": {"type": "string"}
      }
    },
    "required": ["text", "imagePaths"]
  }
}
```

**Returns:**
```json
{
  "success": true,
  "uri": "at://did:plc:.../app.bsky.feed.post/...",
  "message": "Post created with 4 images successfully"
}
```

**Constraints:**
- Maximum 4 images per post
- Supported formats: PNG, JPEG, WebP

**Example Usage:**
```
Agent: Call post_with_gallery with text="Photo collection" and imagePaths=["/path/to/img1.png", "/path/to/img2.png", "/path/to/img3.png"]
Response: {success: true, uri: "at://...", message: "Post created with 3 images successfully"}
```

---

### `post_with_video`

Create a post with a video attachment.

**Status:** ✅ Implemented

**Schema:**
```json
{
  "name": "post_with_video",
  "description": "Create a post with a video",
  "inputSchema": {
    "type": "object",
    "properties": {
      "text": {
        "type": "string",
        "description": "Post text content"
      },
      "videoPath": {
        "type": "string",
        "description": "Path to video file (MP4 format required)"
      }
    },
    "required": ["text", "videoPath"]
  }
}
```

**Returns:**
```json
{
  "success": true,
  "uri": "at://did:plc:.../app.bsky.feed.post/...",
  "message": "Post created with video successfully"
}
```

**Constraints:**
- Video must be MP4 format
- Maximum file size: 100MB (may vary by instance)
- Maximum duration: 5 minutes

**Example Usage:**
```
Agent: Call post_with_video with text="Check out this video!" and videoPath="/path/to/video.mp4"
Response: {success: true, uri: "at://...", message: "Post created with video successfully"}
```

---

### `upload_media`

Upload media file for use in posts or profiles.

**Status:** ✅ Implemented

**Schema:**
```json
{
  "name": "upload_media",
  "description": "Upload a media file",
  "inputSchema": {
    "type": "object",
    "properties": {
      "filePath": {
        "type": "string",
        "description": "Path to media file to upload"
      },
      "mediaType": {
        "type": "string",
        "enum": ["image", "video"],
        "description": "Type of media being uploaded"
      }
    },
    "required": ["filePath", "mediaType"]
  }
}
```

**Returns:**
```json
{
  "success": true,
  "cid": "bafy...",
  "url": "https://...",
  "message": "Media uploaded successfully"
}
```

**Example Usage:**
```
Agent: Call upload_media with filePath="/path/to/image.png" and mediaType="image"
Response: {success: true, cid: "bafy...", url: "https://...", message: "Media uploaded successfully"}
```

---

## Error Response Format

All tools use consistent error responses:

```json
{
  "success": false,
  "error": "error_code",
  "message": "Human-readable error message",
  "details": {
    "field": "additional context"
  }
}
```

**Standard Error Codes:**
- `auth_required` - Authentication needed
- `auth_invalid` - Invalid credentials
- `not_found` - Resource not found
- `invalid_input` - Invalid parameters
- `rate_limited` - Too many requests
- `server_error` - Server-side error
- `network_error` - Network connectivity issue

---

## Tool Implementation Status

| Category | Tool | Status | Phase |
|----------|------|--------|-------|
| **Authentication** | `auth_login` | ✅ Implemented | 1 |
| | `auth_logout` | ✅ Implemented | 1 |
| | `auth_whoami` | ✅ Implemented | 1 |
| | `auth_is_authenticated` | ✅ Implemented | 1 |
| **Engagement** | `post_create` | ✅ Implemented | 1 |
| | `post_reply` | ✅ Implemented | 1 |
| | `post_like` | ✅ Implemented | 1 |
| | `post_repost` | ✅ Implemented | 1 |
| | `post_delete` | ✅ Implemented | 1 |
| **Social** | `follow_user` | ✅ Implemented | 1 |
| | `unfollow_user` | ✅ Implemented | 1 |
| | `get_followers` | ✅ Implemented | 1 |
| | `get_following` | ✅ Implemented | 1 |
| | `block_user` | ✅ Implemented | 1 |
| | `unblock_user` | ✅ Implemented | 1 |
| **Search & Discovery** | `search_posts` | ✅ Implemented | 1 |
| | `read_feed` | ✅ Implemented | 1 |
| | `search_users` | ✅ Implemented | 1 |
| **Media** | `post_with_image` | ✅ Implemented | 1 |
| | `post_with_gallery` | ✅ Implemented | 1 |
| | `post_with_video` | ✅ Implemented | 1 |
| | `upload_media` | ✅ Implemented | 1 |

**Status Legend:**
- ✅ Implemented - Tool is fully functional
- ⏳ Planned - Scheduled for future phase
- 🔄 In Progress - Currently being developed

---

## Batch Operations (Future - Phase 3)

Planned batch tools for efficient operations:

- `batch_post` - Create multiple posts
- `batch_follow` - Follow multiple users
- `batch_schedule` - Schedule multiple operations
- `batch_search` - Perform multiple searches

See PLAN.md for timeline.

---

*Last updated: October 28, 2025*  
For integration examples, see MCP_INTEGRATION.md*