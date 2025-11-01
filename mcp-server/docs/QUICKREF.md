# atproto MCP Quick Reference

Quick reference for using atproto MCP tools in GitHub Copilot or Claude.

## Quick Start

```bash
# Install
sudo ./install.sh --mcp

# Login
atproto login

# Test in Copilot Chat
@workspace Use atproto to check who I'm logged in as
```

## Common Commands

### Authentication
```
Use atproto to check who I'm logged in as
Use atproto to login to Bluesky
Use atproto to logout
```

### Posting
```
Use atproto to post "Hello Bluesky! #test"
Use atproto to reply to [POST_URI] with "Great post!"
Use atproto to like [POST_URI]
Use atproto to repost [POST_URI]
```

### Feed & Discovery
```
Use atproto to read my latest 10 posts
Use atproto to search for posts about "AI"
Use atproto to search for users named "developer"
```

### Social Actions
```
Use atproto to follow user.bsky.social
Use atproto to get my followers
Use atproto to get who I'm following
Use atproto to unfollow user.bsky.social
```

### Profile Management
```
Use atproto to get profile for user.bsky.social
Use atproto to block spam.bsky.social
Use atproto to unblock user.bsky.social
```

## Tool Categories

| Category | Tools | Use For |
|----------|-------|---------|
| **Auth** | login, logout, whoami, is_authenticated | Authentication management |
| **Content** | post_create, post_reply, post_like, post_repost, post_delete | Creating and managing content |
| **Feed** | feed_read, feed_search, feed_timeline, feed_notifications | Reading feeds and notifications |
| **Profile** | profile_get, profile_follow, profile_unfollow, profile_block | Managing profiles and connections |
| **Search** | search_posts, search_users, search_feeds | Discovering content and users |
| **Social** | follow_user, unfollow_user, block_user, get_followers, get_following | Social interactions |
| **Media** | upload_media, post_with_image, post_with_gallery | Media uploads |

## Pro Tips

### Hashtags
Hashtags are automatically detected and formatted:
```
Use atproto to post "Check out #atproto #Bluesky #OpenSource"
```

### Batch Operations
```
Use atproto to:
1. Search for posts about "TypeScript"
2. Like the top 3 posts
3. Follow their authors
```

### Scheduled Posts
```
Generate 5 post ideas about AI, then use atproto to post the best one
```

### Content Curation
```
Use atproto to:
1. Read my feed
2. Find the most engaging posts
3. Repost the top one with a comment
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `ATP_PDS` | `https://bsky.social` | AT Protocol server |
| `MCP_LOG_LEVEL` | `info` | Logging level (debug/info/warn/error) |
| `DEBUG` | `0` | Enable debug mode |

## Troubleshooting

### Not Working?
```bash
# Check installation
which atproto

# Test MCP server
atproto mcp-server --help

# Verify authentication
atproto whoami
```

### Tools Not Appearing?
1. Reload VS Code: `Ctrl+Shift+P` → `Developer: Reload Window`
2. Check settings: `github.copilot.chat.mcp.enabled` = `true`
3. Verify MCP server config in settings.json

### Authentication Failed?
```bash
atproto logout
atproto login
atproto whoami
```

## Links

- **Full Setup Guide**: [VSCODE_SETUP.md](VSCODE_SETUP.md)
- **Tool Documentation**: [MCP_TOOLS.md](MCP_TOOLS.md)
- **Integration Guide**: [MCP_INTEGRATION.md](MCP_INTEGRATION.md)
- **GitHub**: https://github.com/p3nGu1nZz/atproto

---

*Quick Reference v1.0 - October 31, 2025*
