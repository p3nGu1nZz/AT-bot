# MCP Registry Submission Guide

This guide walks through submitting `@atproto/mcp-server` to the official Model Context Protocol registry.

## Prerequisites

- [x] Package published to npm
- [x] Documentation complete
- [x] Registry entry created (`mcp-registry.json`)
- [x] GitHub account with access

## Submission Process

### 1. Fork the MCP Registry Repository

```bash
# Visit: https://github.com/modelcontextprotocol/registry
# Click "Fork" button
```

### 2. Clone Your Fork

```bash
git clone https://github.com/YOUR_USERNAME/registry.git mcp-registry
cd mcp-registry
```

### 3. Create a New Branch

```bash
git checkout -b add-atproto-mcp-server
```

### 4. Add Your Server Entry

The MCP registry uses a specific structure. Create or update the appropriate category file:

```bash
# For AT Protocol/Bluesky integration, add to:
# src/servers/social.json or src/servers/automation.json

# Or create a new entry in:
# src/servers/index.json
```

**Entry format** (based on registry schema):

```json
{
  "id": "atproto-mcp-server",
  "name": "@atproto/mcp-server",
  "description": "Model Context Protocol server for Bluesky/AT Protocol - enables AI agents to interact with the decentralized social network",
  "author": "atproto Contributors",
  "homepage": "https://github.com/p3nGu1nZz/atproto",
  "repository": "https://github.com/p3nGu1nZz/atproto",
  "npm": "@atproto/mcp-server",
  "categories": ["social", "automation", "communication"],
  "keywords": [
    "bluesky",
    "at-protocol",
    "social-media",
    "decentralized",
    "automation",
    "ai-agent"
  ],
  "tools": 29,
  "capabilities": [
    "authentication",
    "posting",
    "reading",
    "social",
    "search",
    "batch_operations",
    "media_upload",
    "rich_text"
  ],
  "configuration": {
    "type": "command",
    "command": "atproto-mcp-server"
  },
  "documentation": "https://github.com/p3nGu1nZz/atproto/blob/main/mcp-server/README.md",
  "examples": "https://github.com/p3nGu1nZz/atproto/blob/main/mcp-server/docs/MCP_TOOLS.md"
}
```

### 5. Validate Your Entry

```bash
# If the registry has validation scripts
npm install
npm run validate

# Or manually check:
# - JSON is valid
# - All required fields present
# - Links work
# - Package exists on npm
```

### 6. Commit and Push

```bash
git add .
git commit -m "feat: add @atproto/mcp-server to registry

Add Model Context Protocol server for Bluesky/AT Protocol integration.
Provides 29 tools for AI agents to interact with the decentralized 
social network including authentication, posting, feeds, and more.

- Package: @atproto/mcp-server
- Categories: social, automation, communication
- Tools: 29
- Repository: https://github.com/p3nGu1nZz/atproto"

git push origin add-atproto-mcp-server
```

### 7. Create Pull Request

1. Visit your fork on GitHub
2. Click "Pull Request" button
3. Title: `feat: add @atproto/mcp-server`
4. Description template:

```markdown
## Add @atproto/mcp-server to MCP Registry

### Package Information
- **Name**: @atproto/mcp-server
- **Version**: 0.1.0
- **NPM**: https://www.npmjs.com/package/@atproto/mcp-server
- **Repository**: https://github.com/p3nGu1nZz/atproto

### Description
Model Context Protocol server for Bluesky/AT Protocol. Enables AI agents to 
interact with the decentralized social network through 29 tools for authentication, 
posting, feeds, profiles, search, and batch operations.

### Categories
- Social Media Integration
- Automation
- Communication

### Key Features
- 29 MCP tools covering full Bluesky functionality
- Secure session management with AES-256-CBC encryption
- Rich text support (hashtags, mentions, URLs)
- Batch operations for bulk actions
- Media upload support
- Search and discovery capabilities

### Installation
```bash
npm install -g @atproto/mcp-server
```

### Configuration Example (Claude Desktop)
```json
{
  "mcpServers": {
    "atproto": {
      "command": "atproto-mcp-server"
    }
  }
}
```

### Testing
Tested with:
- ✅ Claude Desktop
- ✅ VS Code Copilot
- ✅ Claude.ai Projects
- ✅ Direct MCP client integration

### Documentation
- [Quick Start Guide](https://github.com/p3nGu1nZz/atproto/blob/main/mcp-server/README.md)
- [Tool Documentation](https://github.com/p3nGu1nZz/atproto/blob/main/mcp-server/docs/MCP_TOOLS.md)
- [Integration Examples](https://github.com/p3nGu1nZz/atproto/blob/main/mcp-server/docs/MCP_INTEGRATION.md)

### Checklist
- [x] Package published to npm
- [x] Documentation complete
- [x] Tested with MCP clients
- [x] Security best practices followed
- [x] Examples provided
- [x] README with installation instructions
```

### 8. Wait for Review

The MCP registry maintainers will review your submission. They may:
- Request changes
- Ask for additional documentation
- Verify functionality
- Merge your PR

## Alternative: Self-Hosted Registry Entry

If waiting for official registry approval, you can also:

1. **Add to your own README** with installation badge
2. **Submit to alternative directories**:
   - Awesome MCP lists
   - GitHub topics: `mcp-server`, `model-context-protocol`
   - Dev.to / Medium articles
3. **Create GitHub Discussion** in MCP community

## Post-Submission

Once accepted:

1. **Update your README** with registry badge
2. **Announce** on social media
3. **Monitor issues** for user feedback
4. **Keep updated** with MCP specification changes

## Resources

- [MCP Registry](https://github.com/modelcontextprotocol/registry)
- [MCP Specification](https://modelcontextprotocol.io/)
- [MCP Discord](https://discord.gg/mcp) (if available)
- [Our MCP Documentation](./MCP_TOOLS.md)

## Troubleshooting

### PR Rejected - Missing Fields
- Ensure all required fields in registry schema are present
- Check JSON is valid
- Verify npm package is public and accessible

### PR Rejected - Validation Failed
- Run registry validation locally
- Check all links are accessible
- Verify package.json metadata matches

### PR Rejected - Duplicate Entry
- Search existing entries first
- If similar server exists, explain unique features
- Consider collaboration with existing maintainers

---

**Status**: Ready for submission after npm publish  
**Last Updated**: November 1, 2025
