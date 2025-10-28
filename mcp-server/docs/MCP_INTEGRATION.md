# MCP Integration Strategy

This document outlines how AT-bot's MCP server will integrate into the broader MCP ecosystem, particularly with Claude Copilot and other AI agents.

## What is MCP?

**Model Context Protocol (MCP)** is an open standard for connecting AI models and agents to data sources and tools. It uses JSON-RPC 2.0 over stdio, making it language-agnostic and lightweight.

### Key Properties of MCP

- **Language-Agnostic**: Works with any language (Python, Go, Node.js, Rust, etc.)
- **Discoverable**: Agents can automatically discover available tools
- **Composable**: Tools can be combined and chained
- **Secure**: Built-in authentication and permission management
- **Extensible**: New tools can be added without protocol changes

## AT-bot MCP Server Overview

### Core Concept

AT-bot exposes Bluesky/AT Protocol capabilities as MCP tools, allowing AI agents to:
- Authenticate with Bluesky
- Create and manage posts
- Read feeds and timelines
- Follow/unfollow users
- Search content
- And more...

All through standardized MCP tool calls instead of shell command parsing.

### Architecture

```
┌─────────────────────────────────────┐
│   AI Agent (Claude, ChatGPT, etc)  │
└────────────┬────────────────────────┘
             │ MCP Protocol
             │ (JSON-RPC 2.0 / stdio)
             ▼
┌─────────────────────────────────────┐
│   AT-bot MCP Server                 │
│  (Tool Discovery & Execution)       │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│   lib/atproto.sh                    │
│   (Shared core logic)               │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│   Bluesky / AT Protocol             │
└─────────────────────────────────────┘
```

## Integration with Copilot

### How It Works

1. **User Configuration**
   ```json
   {
     "mcpServers": {
       "at-bot": {
         "command": "at-bot-mcp-server",
         "args": [],
         "env": {
           "ATP_PDS": "https://bsky.social"
         }
       }
     }
   }
   ```

2. **Agent Interaction**
   ```
   User: "Post a message to Bluesky about our latest release"
   
   Claude:
   - Discovers available tools from at-bot MCP server
   - Sees: post_create tool available
   - Generates post content
   - Calls: post_create {text: "Check out our latest release..."}
   - Returns: {success: true, uri: "at://..."}
   - Confirms: "Posted to Bluesky successfully!"
   ```

3. **Tool Categories**

   **Authentication**
   - `auth_login` - Authenticate user
   - `auth_logout` - Clear session
   - `auth_whoami` - Current user info
   - `auth_is_authenticated` - Check auth status

   **Content**
   - `post_create` - Create a post
   - `post_reply` - Reply to post
   - `post_like` - Like a post
   - `post_repost` - Repost content
   - `post_delete` - Delete a post

   **Feed**
   - `feed_read` - Read user feed
   - `feed_search` - Search posts
   - `feed_timeline` - Get timeline
   - `feed_notifications` - Get notifications

   **Profile**
   - `profile_get` - Get user profile
   - `profile_follow` - Follow user
   - `profile_unfollow` - Unfollow user
   - `profile_block` - Block user
   - `profile_unblock` - Unblock user

## Implementation Roadmap

### Phase 1: Design (Now - Dec 2025)
- ✅ Define architecture and tool schemas
- ✅ Document integration strategy
- [ ] Create proof-of-concept MCP server
- [ ] Write MCP server documentation

### Phase 2: Development (Jan - Apr 2026)
- [ ] Implement full MCP server
- [ ] Implement all core tools
- [ ] Create comprehensive tests
- [ ] Publish to package registries
- [ ] Create integration guides

### Phase 3: Integration (May - Aug 2026)
- [ ] Integrate with Copilot MCP toolset
- [ ] Build VS Code examples
- [ ] Create agent workflow examples
- [ ] Establish MCP server marketplace presence

### Phase 4: Ecosystem (Sep 2026+)
- [ ] Lead MCP standardization efforts
- [ ] Build cross-protocol bridges
- [ ] Create advanced agent patterns
- [ ] Establish industry standards

## Use Cases Enabled by MCP

### 1. Content Creation Agent
```
Agent: "Schedule 5 posts about our product launch"
→ Creates posts with images, hashtags, timing
→ Uses post_create tool 5 times
→ Returns confirmation with URIs
```

### 2. Community Management Agent
```
Agent: "Respond to mentions with helpful links"
→ Discovers mentions via feed_notifications
→ Analyzes sentiment/topics
→ Uses post_reply tool to respond
→ Logs interactions for analytics
```

### 3. Data Collection Agent
```
Agent: "Collect sentiment data on our brand"
→ Uses feed_search tool with keywords
→ Aggregates results over time
→ Analyzes trends
→ Reports findings
```

### 4. Release Management Agent
```
Agent: "Announce new release and updates"
→ Gets release notes from CI/CD system
→ Uses post_create for announcement
→ Uses profile_follow to engage with followers
→ Uses feed_search to find reactions
```

### 5. Research Agent
```
Agent: "Monitor discussions about AT Protocol"
→ Uses feed_search continuously
→ Extracts key insights
→ Identifies influential voices
→ Generates research reports
```

## Security & Privacy

### Authentication Flow

```
1. User sets up at-bot with:
   - Bluesky handle
   - App password (NOT main password)
   
2. Session token stored locally (~/.config/at-bot/session.json)
   - Permissions: 600 (owner only)
   
3. Agent gets access via:
   - MCP connection (isolated process)
   - No direct access to credentials
   - Limited permissions for agent
   - Audit logging of all actions
```

### Permission Model

Each tool will have configurable permissions:
- Read-only vs write access
- Rate limiting per agent
- Expiration times
- Scope restrictions (which data can be accessed)

### Best Practices

1. Use app passwords, not main account passwords
2. Create separate app passwords for different agents
3. Monitor activity through audit logs
4. Set appropriate rate limits
5. Use environment-specific credentials

## Integration with Development Workflow

### For Developers

```bash
# Install AT-bot with MCP server support
at-bot install --with-mcp

# Start MCP server manually for testing
at-bot-mcp-server --debug

# Configure for Copilot
at-bot configure-mcp --copilot
```

### For AI Assistants

```python
# In Claude Projects or other MCP-compatible systems
import mcp_client

client = mcp_client.MCPClient()
tools = client.discover_tools("at-bot")

# Use tools directly
result = tools["post_create"]({
    "text": "Hello from Claude!"
})
```

## Competitive Advantages

### vs Manual API Integration
- ✅ No need to understand AT Protocol internals
- ✅ Automatic tool discovery
- ✅ Built-in error handling
- ✅ Session management handled

### vs CLI Parsing
- ✅ Structured data instead of text parsing
- ✅ Better error semantics
- ✅ Type safety
- ✅ Extensible tool definitions

### vs Custom Solutions
- ✅ Standard protocol (MCP)
- ✅ Works with multiple agents
- ✅ Community-supported
- ✅ Better security model

## Getting Started

### For Users

1. Install AT-bot with MCP support
2. Generate Bluesky app password
3. Configure MCP in your AI assistant
4. Start using Bluesky in your agent interactions

### For Developers

1. Clone AT-bot repository
2. Review ARCHITECTURE.md for design details
3. Implement MCP server wrapper
4. Define tool schemas
5. Write tests and documentation
6. Submit for inclusion in MCP registry

### For AI Agent Builders

1. Add AT-bot MCP server to your project
2. Discover available tools
3. Build agent workflows using Bluesky capabilities
4. Test and deploy

## Future Enhancements

### MCP Server Features (Post-v1.0)
- Batch operations for efficiency
- Webhook handling for real-time events
- Advanced caching strategies
- Request batching and optimization
- Rate limit management

### Cross-Platform Support
- Support for custom AT Protocol servers
- Federation with other social networks
- Multi-account management
- Advanced permission models

### Agent Ecosystem
- MCP server marketplace discovery
- Pre-built agent templates
- Integration with other MCP servers
- Advanced orchestration patterns

## References

- [MCP Specification](https://modelcontextprotocol.io/)
- [AT Protocol Documentation](https://atproto.com/)
- [Bluesky API Reference](https://docs.bsky.app/)
- [Claude Copilot Integration](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot)

## Contributing

We welcome contributions to the MCP server implementation:

1. Review ARCHITECTURE.md and this document
2. Check TODO.md for current tasks
3. Follow STYLE.md guidelines
4. Create tests for new tools
5. Submit pull requests

---

*Last updated: October 28, 2025*  
*For implementation details, see ARCHITECTURE.md and AGENTS.md*