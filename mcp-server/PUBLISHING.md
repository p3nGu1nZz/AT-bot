# MCP Server Publishing Guide

This document provides step-by-step instructions for publishing the @atproto/mcp-server package to npm and announcing it to the community.

## Prerequisites

- npm account ([Sign up at npmjs.com](https://www.npmjs.com/signup))
- npm CLI installed and logged in
- Git repository access
- Bluesky account for announcements

## Step 1: npm Login

If you haven't logged in to npm yet:

```bash
npm login
# Follow prompts for username, password, and email
# You may need 2FA code if enabled
```

Verify you're logged in:
```bash
npm whoami
```

## Step 2: Final Pre-Publish Checks

### Verify Package Contents

```bash
cd mcp-server
npm pack --dry-run
```

Expected output:
- Package size: ~23 kB
- Files: 54 (dist/, README.md, docs/, config)
- No source code (src/ excluded)
- No tests (tests/ excluded)

### Test Package Locally

```bash
# Create test tarball
npm pack

# Install globally from tarball
npm install -g atproto-mcp-server-0.1.0.tgz

# Test it works
atproto-mcp-server --version

# Clean up
npm uninstall -g @atproto/mcp-server
rm atproto-mcp-server-0.1.0.tgz
```

### Run Final Build

```bash
npm run build
```

Ensure clean TypeScript compilation with no errors.

## Step 3: Publish to npm

### Publish with Public Access

```bash
cd /path/to/atproto/mcp-server
npm publish --access public
```

**Note:** The `--access public` flag is required for scoped packages (@atproto/*).

### Verify Publication

```bash
# Check package on npm
npm info @atproto/mcp-server

# Try installing it
npm install -g @atproto/mcp-server

# Verify it works
atproto-mcp-server --version
```

## Step 4: Update Main README

Add npm badge to main README:

```markdown
[![npm version](https://img.shields.io/npm/v/@atproto/mcp-server.svg)](https://www.npmjs.com/package/@atproto/mcp-server)
```

Update installation instructions:

```markdown
### npm Installation (Recommended)
\`\`\`bash
npm install -g @atproto/mcp-server
\`\`\`
```

Commit and push:
```bash
git add README.md
git commit -m "docs: add npm package badge and installation instructions"
git push origin main
```

## Step 5: Submit to GitHub MCP Registry

### Create GitHub Issue/PR

1. Go to [MCP Registry Repository](https://github.com/modelcontextprotocol/servers)
2. Create a new issue or PR with the following:

**Title:** Add @atproto/mcp-server - Bluesky/AT Protocol MCP Server

**Body:**
```markdown
## Package Information

- **Name:** @atproto/mcp-server
- **Description:** Model Context Protocol server for Bluesky/AT Protocol
- **npm:** https://www.npmjs.com/package/@atproto/mcp-server
- **Repository:** https://github.com/p3nGu1nZz/atproto
- **License:** MIT

## Tools Provided (34)

- Authentication (4): login, logout, whoami, is_authenticated
- Content (5): create post, reply, like, repost, delete
- Feed (4): read feed, search, timeline, notifications
- Profile (4): get profile, follow, unfollow, block
- Social (6): follow/unfollow, block/unblock, get followers/following
- Search (3): search posts, users, timeline
- Batch (5): batch operations for efficiency
- Engagement (3): like, repost, delete

## Installation

\`\`\`bash
npm install -g @atproto/mcp-server
\`\`\`

## Configuration

### Claude Desktop
\`\`\`json
{
  "mcpServers": {
    "atproto": {
      "command": "atproto-mcp-server"
    }
  }
}
\`\`\`

### VS Code
\`\`\`json
{
  "github.copilot.advanced": {
    "mcp.servers": {
      "atproto": {
        "command": "atproto-mcp-server"
      }
    }
  }
}
\`\`\`

## Documentation

- [Full Documentation](https://github.com/p3nGu1nZz/atproto/blob/main/mcp-server/README.md)
- [Tool Reference](https://github.com/p3nGu1nZz/atproto/blob/main/mcp-server/docs/MCP_TOOLS.md)
- [Integration Guides](https://github.com/p3nGu1nZz/atproto/tree/main/mcp-server/docs/integrations)

## Use Cases

- AI-powered social media automation
- Bluesky bot development
- Content management and scheduling
- Research and data collection
- Cross-platform social media integration
```

3. Include `mcp-server/mcp-registry.json` as attachment

## Step 6: Create Announcement Post

### Bluesky Announcement

```bash
atproto login
atproto post "🎉 Big news! @atproto/mcp-server is now on npm! 

Model Context Protocol server for Bluesky - enables AI agents like Claude and Copilot to interact with AT Protocol seamlessly.

✨ 34 tools for posts, search, social, and more
📦 npm install -g @atproto/mcp-server
🔗 https://www.npmjs.com/package/@atproto/mcp-server

#atprotocol #MCP #AI #Bluesky #OpenSource"
```

Alternative shorter version:
```bash
atproto post "🚀 Just published @atproto/mcp-server v0.1.0 to npm!

Enable AI agents to interact with Bluesky through Model Context Protocol.

34 tools | Easy setup | MIT license

npm install -g @atproto/mcp-server

#atprotocol #MCP"
```

## Step 7: Share in Communities

### Twitter/X
```
🎉 @atproto/mcp-server is now on npm!

Model Context Protocol server for Bluesky/AT Protocol
- 34 tools for AI agents
- Works with Claude Desktop, VS Code Copilot
- MIT licensed

npm install -g @atproto/mcp-server

Docs: https://github.com/p3nGu1nZz/atproto

#atprotocol #MCP #AI
```

### Reddit

**r/atproto:**
```markdown
**@atproto/mcp-server v0.1.0 Released on npm**

I'm excited to announce the release of @atproto/mcp-server, a Model Context Protocol server that enables AI agents to interact with Bluesky and AT Protocol.

**Features:**
- 34 MCP tools covering authentication, posting, social interactions, search, and more
- Works with Claude Desktop, VS Code Copilot, and other MCP-compatible applications
- Simple installation via npm: `npm install -g @atproto/mcp-server`
- Comprehensive documentation and integration guides

**Links:**
- npm: https://www.npmjs.com/package/@atproto/mcp-server
- GitHub: https://github.com/p3nGu1nZz/atproto
- Documentation: [Link to docs]

**Use Cases:**
- AI-powered social media automation
- Building Bluesky bots
- Content management and scheduling
- Research and data collection

Feedback and contributions welcome!
```

**r/MachineLearning (if appropriate):**
Similar post focusing on AI/ML angle.

### Discord Servers

**AT Protocol Discord:**
```
Hey everyone! 👋

Just released @atproto/mcp-server v0.1.0 on npm - a Model Context Protocol server for Bluesky/AT Protocol.

It lets AI agents like Claude and Copilot interact with Bluesky directly through 34 standardized tools.

npm install -g @atproto/mcp-server

Check it out: https://github.com/p3nGu1nZz/atproto
```

**MCP Community Discord:**
Similar announcement focused on MCP integration.

### Hacker News

Submit to Show HN:
```markdown
**Title:** Show HN: MCP Server for Bluesky/AT Protocol

**Body:**
I built a Model Context Protocol server that gives AI agents access to Bluesky/AT Protocol. It provides 34 tools for authentication, posting, social interactions, search, and batch operations.

The server works with Claude Desktop, VS Code Copilot, and other MCP-compatible applications. Setup is simple - just install via npm and add a few lines to your MCP config.

Main use cases: AI-powered bots, content automation, research tools, and cross-platform integrations.

Would love feedback from the community!

GitHub: https://github.com/p3nGu1nZz/atproto
npm: https://www.npmjs.com/package/@atproto/mcp-server
```

### LinkedIn (Professional Networks)

```markdown
Excited to announce @atproto/mcp-server v0.1.0! 🚀

A Model Context Protocol server for Bluesky/AT Protocol that enables AI agents to interact with decentralized social networks.

Key highlights:
✅ 34 standardized MCP tools
✅ Works with Claude, Copilot, and other AI agents
✅ Easy npm installation
✅ MIT licensed and open source

This bridges AI agents and decentralized social media, opening up new possibilities for automation, research, and innovation.

Check it out: https://github.com/p3nGu1nZz/atproto

#AI #OpenSource #Decentralization #SocialMedia #MCP
```

## Step 8: Monitor and Respond

### Track Metrics

Monitor these after publishing:
- npm downloads: `npm info @atproto/mcp-server`
- GitHub stars/forks: Check repository insights
- Community feedback: Issues, discussions, social mentions

### Respond to Feedback

- Answer questions promptly
- Address issues and bugs quickly
- Thank contributors and users
- Incorporate feedback into roadmap

## Step 9: Follow-Up Actions

### Week 1
- [ ] Monitor npm downloads
- [ ] Respond to GitHub issues/discussions
- [ ] Update documentation based on feedback
- [ ] Fix any critical bugs

### Week 2-4
- [ ] Write blog post about implementation
- [ ] Create video tutorial/demo
- [ ] Reach out to MCP ecosystem projects
- [ ] Plan v0.2.0 features based on feedback

### Month 2-3
- [ ] Gather usage metrics
- [ ] Implement requested features
- [ ] Improve documentation
- [ ] Build community

## Troubleshooting

### npm publish fails with auth error
```bash
npm logout
npm login
npm publish --access public
```

### Package name already exists
Scoped packages (@atproto/*) should be unique. If there's a conflict:
- Check npm: `npm info @atproto/mcp-server`
- Consider alternative name or version bump

### Build errors before publish
```bash
rm -rf dist node_modules
npm install
npm run build
npm publish --access public
```

### 2FA Issues
If you have 2FA enabled:
```bash
npm publish --access public --otp=123456
# Replace 123456 with your current 2FA code
```

## Checklist

Publishing checklist before you proceed:

- [ ] npm login successful (`npm whoami` works)
- [ ] Package builds cleanly (`npm run build`)
- [ ] Dry-run looks good (`npm publish --dry-run`)
- [ ] README.md is user-friendly
- [ ] Documentation is complete
- [ ] Tests pass
- [ ] Version number is correct (v0.1.0)
- [ ] Git is on latest commit
- [ ] Ready to announce on social media

## Post-Publishing Verification

After publishing, verify:

```bash
# Wait 1-2 minutes for npm propagation

# Check package exists
npm info @atproto/mcp-server

# Install globally
npm install -g @atproto/mcp-server

# Verify command works
atproto-mcp-server --version

# Test with Claude Desktop or VS Code
# (follow integration guides)
```

---

**Ready to publish?** Start with Step 1 and work through each step carefully. Good luck! 🚀

*Document created: November 1, 2025*
