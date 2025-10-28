# AT-bot MCP Tools Reference

This document provides detailed specifications for all MCP tools exposed by the AT-bot MCP server. Each tool includes its schema, parameters, return values, and example usage.

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

## Content Tools

### `post_create`

Create a new post on Bluesky.

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
      "replyTo": {
        "type": "string",
        "description": "Optional AT-URI of post to reply to"
      },
      "attachments": {
        "type": "array",
        "description": "Optional media attachments",
        "items": {
          "type": "object",
          "properties": {
            "type": {
              "type": "string",
              "enum": ["image", "video"]
            },
            "url": {
              "type": "string",
              "description": "URL or file path to media"
            }
          }
        }
      },
      "labels": {
        "type": "array",
        "description": "Optional content labels",
        "items": {"type": "string"}
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
Agent: Call post_create with text="Hello from AT-bot MCP! 🤖"
Response: {success: true, uri: "at://...", cid: "bafy..."}
```

**Constraints:**
- Maximum 300 characters
- Maximum 4 images or 1 video per post
- Must be authenticated

---

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
        "description": "Maximum results to return (default: 10)",
        "default": 10
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

### `user_follow`

Follow a user on Bluesky.

**Status:** ✅ Implemented

**Schema:**
```json
{
  "name": "user_follow",
  "description": "Follow a user",
  "inputSchema": {
    "type": "object",
    "properties": {
      "handle": {
        "type": "string",
        "description": "User handle or DID (e.g., user.bsky.social)"
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
Agent: Call user_follow with handle="user.bsky.social"
Response: {success: true, message: "Successfully followed: user.bsky.social"}
```

---

### `user_unfollow`

Unfollow a user on Bluesky.

**Status:** ✅ Implemented

**Schema:**
```json
{
  "name": "user_unfollow",
  "description": "Unfollow a user",
  "inputSchema": {
    "type": "object",
    "properties": {
      "handle": {
        "type": "string",
        "description": "User handle or DID (e.g., user.bsky.social)"
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
Agent: Call user_unfollow with handle="user.bsky.social"
Response: {success: true, message: "Successfully unfollowed: user.bsky.social"}
```

---

### `post_reply`

Reply to an existing post.

**Schema:**
```json
{
  "name": "post_reply",
  "description": "Reply to a post",
  "inputSchema": {
    "type": "object",
    "properties": {
      "replyTo": {
        "type": "string",
        "description": "AT-URI of post to reply to (required)"
      },
      "text": {
        "type": "string",
        "description": "Reply content"
      },
      "attachments": {
        "type": "array",
        "description": "Optional media attachments"
      }
    },
    "required": ["replyTo", "text"]
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

---

### `post_like`

Like an existing post.

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
        "description": "AT-URI of post to like"
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
  "likeUri": "at://..."
}
```

---

### `post_repost`

Repost (rebleet) an existing post.

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
        "description": "AT-URI of post to repost"
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
  "repostUri": "at://..."
}
```

---

### `post_delete`

Delete an existing post.

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
        "description": "AT-URI of post to delete"
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
  "message": "Post deleted"
}
```

---

## Feed Tools

### `feed_read`

Read the authenticated user's home feed.

**Schema:**
```json
{
  "name": "feed_read",
  "description": "Read user's home feed",
  "inputSchema": {
    "type": "object",
    "properties": {
      "limit": {
        "type": "integer",
        "description": "Number of posts to return (1-100, default: 30)"
      },
      "cursor": {
        "type": "string",
        "description": "Pagination cursor from previous request"
      }
    }
  }
}
```

**Returns:**
```json
{
  "posts": [
    {
      "uri": "at://...",
      "cid": "bafy...",
      "author": {
        "did": "did:plc:...",
        "handle": "user.bsky.social",
        "displayName": "User Name"
      },
      "record": {
        "text": "Post content",
        "createdAt": "2025-10-28T10:00:00Z"
      },
      "likeCount": 42,
      "replyCount": 5,
      "repostCount": 10
    }
  ],
  "cursor": "next_page_cursor"
}
```

---

### `feed_search`

Search posts by keyword or hashtag.

**Schema:**
```json
{
  "name": "feed_search",
  "description": "Search posts",
  "inputSchema": {
    "type": "object",
    "properties": {
      "query": {
        "type": "string",
        "description": "Search query (keywords, #hashtags, @mentions)"
      },
      "limit": {
        "type": "integer",
        "description": "Number of results (1-100, default: 30)"
      },
      "sort": {
        "type": "string",
        "enum": ["latest", "top"],
        "description": "Sort order (default: latest)"
      }
    },
    "required": ["query"]
  }
}
```

**Returns:**
```json
{
  "posts": [
    {
      "uri": "at://...",
      "author": {...},
      "record": {...},
      "likeCount": 100
    }
  ],
  "totalHits": 1500
}
```

---

### `feed_timeline`

Get a specific user's timeline.

**Schema:**
```json
{
  "name": "feed_timeline",
  "description": "Get user's timeline",
  "inputSchema": {
    "type": "object",
    "properties": {
      "user": {
        "type": "string",
        "description": "Handle or DID of user"
      },
      "limit": {
        "type": "integer",
        "description": "Number of posts (1-100, default: 30)"
      }
    },
    "required": ["user"]
  }
}
```

**Returns:**
```json
{
  "posts": [...],
  "cursor": "..."
}
```

---

### `feed_notifications`

Get notifications for the authenticated user.

**Schema:**
```json
{
  "name": "feed_notifications",
  "description": "Get user notifications",
  "inputSchema": {
    "type": "object",
    "properties": {
      "limit": {
        "type": "integer",
        "description": "Number of notifications (default: 30)"
      },
      "seenOnly": {
        "type": "boolean",
        "description": "Only return seen notifications"
      }
    }
  }
}
```

**Returns:**
```json
{
  "notifications": [
    {
      "uri": "at://...",
      "cid": "bafy...",
      "author": {...},
      "reason": "like|reply|repost|follow|mention",
      "reasonSubject": "at://...",
      "record": {...},
      "isRead": false,
      "indexedAt": "2025-10-28T10:00:00Z"
    }
  ]
}
```

---

## Profile Tools

### `profile_get`

Get a user's profile information.

**Schema:**
```json
{
  "name": "profile_get",
  "description": "Get user profile",
  "inputSchema": {
    "type": "object",
    "properties": {
      "user": {
        "type": "string",
        "description": "Handle or DID"
      }
    },
    "required": ["user"]
  }
}
```

**Returns:**
```json
{
  "did": "did:plc:...",
  "handle": "alice.bsky.social",
  "displayName": "Alice",
  "description": "Developer",
  "avatar": "https://...",
  "banner": "https://...",
  "followsCount": 500,
  "followersCount": 1000,
  "postsCount": 250,
  "indexed_at": "2025-10-28T10:00:00Z"
}
```

---

### `profile_follow`

Follow a user.

**Schema:**
```json
{
  "name": "profile_follow",
  "description": "Follow a user",
  "inputSchema": {
    "type": "object",
    "properties": {
      "user": {
        "type": "string",
        "description": "Handle or DID of user to follow"
      }
    },
    "required": ["user"]
  }
}
```

**Returns:**
```json
{
  "success": true,
  "followUri": "at://..."
}
```

---

### `profile_unfollow`

Unfollow a user.

**Schema:**
```json
{
  "name": "profile_unfollow",
  "description": "Unfollow a user",
  "inputSchema": {
    "type": "object",
    "properties": {
      "user": {
        "type": "string",
        "description": "Handle or DID to unfollow"
      }
    },
    "required": ["user"]
  }
}
```

**Returns:**
```json
{
  "success": true
}
```

---

### `profile_block`

Block a user.

**Schema:**
```json
{
  "name": "profile_block",
  "description": "Block a user",
  "inputSchema": {
    "type": "object",
    "properties": {
      "user": {
        "type": "string",
        "description": "Handle or DID to block"
      }
    },
    "required": ["user"]
  }
}
```

**Returns:**
```json
{
  "success": true,
  "blockUri": "at://..."
}
```

---

### `profile_unblock`

Unblock a user.

**Schema:**
```json
{
  "name": "profile_unblock",
  "description": "Unblock a user",
  "inputSchema": {
    "type": "object",
    "properties": {
      "user": {
        "type": "string",
        "description": "Handle or DID to unblock"
      }
    },
    "required": ["user"]
  }
}
```

**Returns:**
```json
{
  "success": true
}
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

| Tool | Status | Phase |
|------|--------|-------|
| `auth_login` | ⏳ Planned | 2 |
| `auth_logout` | ⏳ Planned | 2 |
| `auth_whoami` | ⏳ Planned | 2 |
| `auth_is_authenticated` | ⏳ Planned | 2 |
| `post_create` | ⏳ Planned | 2 |
| `post_reply` | ⏳ Planned | 2 |
| `post_like` | ⏳ Planned | 2 |
| `post_repost` | ⏳ Planned | 2 |
| `post_delete` | ⏳ Planned | 2 |
| `feed_read` | ⏳ Planned | 2 |
| `feed_search` | ⏳ Planned | 2 |
| `feed_timeline` | ⏳ Planned | 2 |
| `feed_notifications` | ⏳ Planned | 2 |
| `profile_get` | ⏳ Planned | 2 |
| `profile_follow` | ⏳ Planned | 2 |
| `profile_unfollow` | ⏳ Planned | 2 |
| `profile_block` | ⏳ Planned | 2 |
| `profile_unblock` | ⏳ Planned | 2 |

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