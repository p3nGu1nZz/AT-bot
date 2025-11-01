# Batch Operations Guide

The atproto MCP server now supports batch operations for efficient bulk automation.

## Available Batch Tools

### 1. `batch_post` - Create Multiple Posts

Post multiple messages in one operation. Perfect for content scheduling and bulk posting.

**Usage:**
```json
{
  "posts": [
    {
      "text": "First post content #hashtag"
    },
    {
      "text": "Second post with image",
      "image": "/path/to/image.jpg"
    },
    {
      "text": "Third post"
    }
  ]
}
```

**Example (via MCP):**
```javascript
batch_post({
  posts: [
    { text: "Announcement: New features released! 🚀" },
    { text: "Check out the documentation for details." },
    { text: "Thanks to all contributors! 🙏" }
  ]
})
```

**Response:**
```json
{
  "total": 3,
  "successful": 3,
  "failed": 0,
  "results": [
    { "success": true, "text": "...", "output": "..." },
    { "success": true, "text": "...", "output": "..." },
    { "success": true, "text": "...", "output": "..." }
  ]
}
```

### 2. `batch_follow` - Follow Multiple Users

Follow multiple users in one operation.

**Usage:**
```json
{
  "handles": [
    "user1.bsky.social",
    "user2.bsky.social",
    "user3.bsky.social"
  ]
}
```

**Example:**
```javascript
batch_follow({
  handles: [
    "bsky.app",
    "atproto.com",
    "jay.bsky.team"
  ]
})
```

**Response:**
```json
{
  "total": 3,
  "successful": 3,
  "failed": 0,
  "results": [
    { "success": true, "handle": "bsky.app", "output": "..." },
    ...
  ]
}
```

### 3. `batch_unfollow` - Unfollow Multiple Users

Unfollow multiple users in one operation.

**Usage:**
```json
{
  "handles": [
    "user1.bsky.social",
    "user2.bsky.social"
  ]
}
```

### 4. `batch_like` - Like Multiple Posts

Like multiple posts by their URIs.

**Usage:**
```json
{
  "uris": [
    "at://did:plc:abc123.../app.bsky.feed.post/xyz789",
    "at://did:plc:def456.../app.bsky.feed.post/uvw012"
  ]
}
```

**Example:**
```javascript
batch_like({
  uris: [
    "at://...",
    "at://...",
    "at://..."
  ]
})
```

### 5. `batch_from_file` - Execute Batch Operations from File

Load and execute multiple batch operations from a JSON file.

**File Format:**
```json
{
  "posts": [
    { "text": "Post 1" },
    { "text": "Post 2", "image": "/path/to/image.jpg" }
  ],
  "follows": [
    "user1.bsky.social",
    "user2.bsky.social"
  ],
  "likes": [
    "at://...",
    "at://..."
  ]
}
```

**Usage:**
```javascript
batch_from_file({
  filepath: "/path/to/operations.json"
})
```

**Response:**
```json
{
  "success": true,
  "filepath": "/path/to/operations.json",
  "summary": {
    "posts": "2/2",
    "follows": "2/2",
    "likes": "2/2"
  },
  "details": {
    "posts": { "total": 2, "successful": 2, "failed": 0, "results": [...] },
    "follows": { "total": 2, "successful": 2, "failed": 0, "results": [...] },
    "likes": { "total": 2, "successful": 2, "failed": 0, "results": [...] }
  }
}
```

## Use Cases

### Content Scheduling

Schedule multiple posts for a content campaign:

```javascript
batch_post({
  posts: [
    { text: "Day 1: Introduction to our new feature 🎉" },
    { text: "Day 2: How to get started [link]" },
    { text: "Day 3: Advanced tips and tricks 💡" },
    { text: "Day 4: Community showcase 🌟" },
    { text: "Day 5: Q&A and wrap-up" }
  ]
})
```

### Community Building

Follow all members of a community or list:

```javascript
batch_follow({
  handles: [
    "member1.bsky.social",
    "member2.bsky.social",
    "member3.bsky.social",
    // ... up to hundreds of users
  ]
})
```

### Engagement Campaigns

Like posts from a curated feed or search results:

```javascript
// First, search for posts
const posts = search_posts({ query: "opensource bluesky", limit: 50 })

// Then, like all results
batch_like({
  uris: posts.map(p => p.uri)
})
```

### Automated Workflows

Combine with file-based operations for scheduled workflows:

```bash
# Create a daily operations file
cat > daily-posts.json << EOF
{
  "posts": [
    { "text": "Good morning! ☀️ #DailyUpdate" },
    { "text": "Today's tip: [your tip here]" }
  ],
  "follows": ["new-user.bsky.social"]
}
EOF

# Execute via MCP
batch_from_file({ filepath: "./daily-posts.json" })
```

## Error Handling

All batch operations include detailed error reporting:

```json
{
  "total": 5,
  "successful": 4,
  "failed": 1,
  "results": [
    { "success": true, "text": "Post 1", "output": "..." },
    { "success": true, "text": "Post 2", "output": "..." },
    { "success": false, "text": "Post 3", "error": "Rate limit exceeded" },
    { "success": true, "text": "Post 4", "output": "..." },
    { "success": true, "text": "Post 5", "output": "..." }
  ]
}
```

- Each operation is executed independently
- Failures don't stop subsequent operations
- Detailed success/failure reporting per item
- Full error messages for debugging

## Best Practices

### 1. Rate Limiting

Be mindful of AT Protocol rate limits:
- Limit batch size to 10-20 items
- Add delays between large batches
- Monitor success/failure rates

### 2. Error Recovery

Check results and retry failed operations:

```javascript
const result = await batch_post({ posts: myPosts })

const failed = result.results.filter(r => !r.success)

if (failed.length > 0) {
  // Retry failed posts
  await batch_post({
    posts: failed.map(f => ({ text: f.text }))
  })
}
```

### 3. File Organization

Organize batch operations by type and schedule:

```
automation/
├── daily-posts.json       # Daily scheduled content
├── weekly-follows.json    # Weekly community building
├── campaign-posts.json    # Marketing campaigns
└── engagement.json        # Engagement activities
```

### 4. Logging and Monitoring

Track batch operation results:

```javascript
const result = await batch_from_file({
  filepath: "./operations.json"
})

console.log(`Summary:`)
console.log(`  Posts: ${result.summary.posts}`)
console.log(`  Follows: ${result.summary.follows}`)
console.log(`  Likes: ${result.summary.likes}`)

// Save results for analysis
fs.writeFileSync(
  `./logs/${Date.now()}-results.json`,
  JSON.stringify(result, null, 2)
)
```

## Integration Examples

### With GitHub Actions

```yaml
name: Daily Bluesky Posts
on:
  schedule:
    - cron: '0 9 * * *'  # 9 AM daily
jobs:
  post:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Post via MCP
        run: |
          # Use MCP server to execute batch operations
          batch_from_file({ filepath: "./content/daily.json" })
```

### With Cron Jobs

```bash
#!/bin/bash
# /etc/cron.daily/bluesky-automation

# Execute daily batch operations
batch_from_file --filepath /path/to/daily-operations.json

# Log results
echo "$(date): Batch operations completed" >> /var/log/bluesky.log
```

### With Agent Workflows

```javascript
// AI agent workflow
async function dailyContentWorkflow() {
  // 1. Generate content
  const posts = await generateDailyPosts()
  
  // 2. Post in batch
  const result = await batch_post({ posts })
  
  // 3. Follow engagement
  if (result.successful > 0) {
    await trackMetrics(result)
  }
  
  return result
}
```

## Security Considerations

- **Credentials**: Use app passwords, not main account password
- **Rate Limits**: Respect platform rate limits
- **Content Review**: Review batch content before posting
- **Logging**: Log operations for audit trails
- **Permissions**: Ensure proper file permissions for batch files

## Troubleshooting

### Batch Operations Failing

1. Check authentication:
   ```javascript
   auth_is_authenticated()
   ```

2. Test with small batch first:
   ```javascript
   batch_post({ posts: [{ text: "Test post" }] })
   ```

3. Check for rate limiting:
   - Reduce batch size
   - Add delays between operations
   - Check AT Protocol status

### File-Based Operations Not Working

1. Verify file path is absolute
2. Check JSON syntax is valid
3. Ensure file has proper read permissions
4. Validate JSON structure matches expected format

## Performance Tips

- **Batch Size**: Keep batches under 20 items for optimal performance
- **Parallel Execution**: Use multiple batch operations for different types
- **Caching**: Cache session data to avoid repeated authentication
- **Monitoring**: Track success rates and adjust batch sizes accordingly

---

For more examples, see the `examples/` directory in the atproto repository.
