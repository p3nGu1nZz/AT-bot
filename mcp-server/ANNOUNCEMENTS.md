# Announcement Templates for @atproto/mcp-server

Ready-to-use announcement templates for various platforms after publishing to npm.

## Bluesky Post (Main Announcement)

**Option 1: Detailed** (280 chars)
```
🎉 Big news! @atproto/mcp-server is now on npm! 

Model Context Protocol server for Bluesky - enables AI agents like Claude and Copilot to interact with AT Protocol seamlessly.

✨ 34 tools for posts, search, social
📦 npm install -g @atproto/mcp-server
🔗 npmjs.com/package/@atproto/mcp-server

#atprotocol #MCP #AI #Bluesky
```

**Option 2: Concise** (shorter)
```
🚀 Just published @atproto/mcp-server v0.1.0!

Enable AI agents to interact with Bluesky through Model Context Protocol.

34 tools | Easy setup | MIT license

npm install -g @atproto/mcp-server

#atprotocol #MCP #OpenSource
```

**Option 3: Technical** (for developer audience)
```
📦 New MCP server for AT Protocol!

@atproto/mcp-server provides 34 tools:
- Authentication & session management
- Posts, replies, engagement
- Search & discovery
- Social graphs & batch ops

Compatible with Claude Desktop, VS Code Copilot, and any MCP client.

npm install -g @atproto/mcp-server

Docs: github.com/p3nGu1nZz/atproto
```

## Twitter/X Post

```
🎉 @atproto/mcp-server is now on npm!

Model Context Protocol server for Bluesky/AT Protocol
- 34 tools for AI agents
- Works with Claude Desktop, VS Code Copilot
- MIT licensed

npm install -g @atproto/mcp-server

Docs: https://github.com/p3nGu1nZz/atproto

#atprotocol #MCP #AI #Bluesky #OpenSource
```

## Reddit Posts

### r/atproto

**Title:** @atproto/mcp-server v0.1.0 - Model Context Protocol Server for Bluesky

**Body:**
```markdown
I'm excited to announce the release of **@atproto/mcp-server**, a Model Context Protocol server that enables AI agents to interact with Bluesky and AT Protocol.

## What is it?

A standards-compliant MCP server that exposes 34 tools for AI agents to interact with Bluesky. Works with Claude Desktop, VS Code Copilot, and other MCP-compatible applications.

## Features

**34 MCP Tools covering:**
- 🔐 Authentication (login, logout, session management)
- 📝 Content creation (posts, replies, threads)
- 💬 Social interactions (follow, block, likes, reposts)
- 🔍 Search & discovery (posts, users, feeds)
- 📦 Batch operations for efficiency
- 🎨 Rich text support (hashtags, mentions, URLs)

## Installation

```bash
npm install -g @atproto/mcp-server
```

## Quick Start

**Claude Desktop:**
```json
{
  "mcpServers": {
    "atproto": {
      "command": "atproto-mcp-server"
    }
  }
}
```

**VS Code Copilot:**
```json
{
  "github.copilot.advanced": {
    "mcp.servers": {
      "atproto": {
        "command": "atproto-mcp-server"
      }
    }
  }
}
```

## Use Cases

- AI-powered social media automation
- Building intelligent Bluesky bots
- Content management and scheduling
- Research and data collection from AT Protocol
- Cross-platform social media integration

## Links

- **npm:** https://www.npmjs.com/package/@atproto/mcp-server
- **GitHub:** https://github.com/p3nGu1nZz/atproto
- **Documentation:** https://github.com/p3nGu1nZz/atproto/tree/main/mcp-server/docs
- **Integration Guides:** 
  - [Claude Desktop](https://github.com/p3nGu1nZz/atproto/blob/main/mcp-server/docs/integrations/CLAUDE_DESKTOP.md)
  - [VS Code Copilot](https://github.com/p3nGu1nZz/atproto/blob/main/mcp-server/docs/integrations/VSCODE_COPILOT.md)

## Technical Details

- **Language:** TypeScript/Node.js
- **Protocol:** JSON-RPC 2.0 over stdio
- **License:** MIT
- **Dependencies:** @modelcontextprotocol/sdk
- **Requirements:** Node.js 18+

## Example Usage

```
# In Claude Desktop:
"Can you post 'Hello from AI! 🤖' to my Bluesky account?"

# In VS Code Copilot:
"@workspace Search Bluesky for posts about 'MCP' and summarize"
```

## Contributing

Contributions welcome! The project follows standard GitHub workflows:
- Issues for bug reports and feature requests
- Pull requests for code contributions
- Discussions for questions and ideas

## Roadmap

Future plans include:
- Advanced media handling (videos, galleries)
- Custom feed creation
- List management
- Notification webhooks
- Analytics and metrics

Feedback and suggestions are appreciated!

---

*Full documentation available at: https://github.com/p3nGu1nZz/atproto*
```

### r/programming (if appropriate)

**Title:** Built an MCP server for Bluesky/AT Protocol - AI agents can now interact with decentralized social media

**Body:**
```markdown
I built a Model Context Protocol (MCP) server that enables AI agents to interact with Bluesky and the AT Protocol. It's now available on npm as @atproto/mcp-server.

## What is MCP?

Model Context Protocol is a standard for connecting AI models to external tools and data sources. It uses JSON-RPC 2.0 over stdio, making it language-agnostic and easy to integrate.

## Why AT Protocol?

AT Protocol is the decentralized social networking protocol behind Bluesky. Unlike centralized platforms, it gives users control over their data and allows for federated social networks.

## What I Built

A TypeScript-based MCP server that exposes 34 tools for interacting with Bluesky:

- Authentication and session management
- Post creation with rich text (hashtags, mentions, URLs)
- Social interactions (follow, block, likes, reposts)
- Search and discovery
- Batch operations for efficiency

The server works with Claude Desktop, VS Code Copilot, and other MCP-compatible applications.

## Installation

```bash
npm install -g @atproto/mcp-server
```

## Technical Architecture

```
AI Agent (Claude, Copilot)
         ↓
   JSON-RPC 2.0 / stdio
         ↓
   MCP Server (Node.js/TypeScript)
         ↓
   Shell Executor → atproto CLI
         ↓
   AT Protocol / Bluesky API
```

The server uses a shell executor pattern to leverage the existing battle-tested atproto CLI, ensuring reliability and security.

## Example Integration

**Claude Desktop config:**
```json
{
  "mcpServers": {
    "atproto": {
      "command": "atproto-mcp-server"
    }
  }
}
```

Then you can simply ask Claude: "Post 'Hello from AI!' to my Bluesky account" and it handles authentication, API calls, and error handling automatically.

## Security Considerations

- Uses app passwords (not main account password)
- Session tokens stored with AES-256-CBC encryption
- Respects AT Protocol rate limits with exponential backoff
- All operations require explicit user authentication

## Links

- GitHub: https://github.com/p3nGu1nZz/atproto
- npm: https://www.npmjs.com/package/@atproto/mcp-server
- Documentation: [Link to docs]

Open to feedback and contributions!
```

## Hacker News (Show HN)

**Title:** Show HN: MCP Server for Bluesky/AT Protocol

**Body:**
```
I built a Model Context Protocol server that gives AI agents access to Bluesky/AT Protocol. It provides 34 tools for authentication, posting, social interactions, search, and batch operations.

The server works with Claude Desktop, VS Code Copilot, and other MCP-compatible applications. Setup is simple - just install via npm and add a few lines to your MCP config.

Main use cases: AI-powered bots, content automation, research tools, and cross-platform integrations with decentralized social networks.

Technical stack: TypeScript/Node.js, JSON-RPC 2.0, uses existing atproto CLI as execution layer for reliability and security.

Would love feedback from the community on features, use cases, and integration approaches!

GitHub: https://github.com/p3nGu1nZz/atproto
npm: https://www.npmjs.com/package/@atproto/mcp-server
```

## LinkedIn Post

```
Excited to announce the release of @atproto/mcp-server v0.1.0! 🚀

A Model Context Protocol server for Bluesky/AT Protocol that bridges AI agents and decentralized social networks.

🔑 Key Highlights:
✅ 34 standardized MCP tools for comprehensive Bluesky interaction
✅ Works with Claude, GitHub Copilot, and other AI agents
✅ Simple npm installation: npm install -g @atproto/mcp-server
✅ MIT licensed and fully open source
✅ Comprehensive documentation and integration guides

🎯 Why This Matters:
This project demonstrates how AI agents can interact with decentralized social protocols, opening new possibilities for:
- Intelligent content automation
- Research and data analysis
- Cross-platform social media management
- Building next-generation social bots

The intersection of AI and decentralized social media is exciting territory. This tool makes it accessible to developers and researchers.

🔗 Links:
GitHub: https://github.com/p3nGu1nZz/atproto
npm: https://www.npmjs.com/package/@atproto/mcp-server
Documentation: [Link to docs]

Feedback and collaboration opportunities welcome!

#AI #OpenSource #Decentralization #SocialMedia #MCP #Bluesky #ATProtocol #Innovation
```

## Discord Announcements

### AT Protocol Discord

```
Hey everyone! 👋

Exciting news - just released @atproto/mcp-server v0.1.0 on npm! 🎉

It's a Model Context Protocol server that lets AI agents like Claude and Copilot interact with Bluesky/AT Protocol directly through 34 standardized tools.

**Quick Install:**
```
npm install -g @atproto/mcp-server
```

**What it does:**
- Authentication & session management
- Post creation, replies, engagement
- Social interactions (follow, block, etc.)
- Search & discovery
- Batch operations

**Works with:**
- Claude Desktop
- VS Code Copilot
- Any MCP-compatible application

**Links:**
📦 npm: https://www.npmjs.com/package/@atproto/mcp-server
🔗 GitHub: https://github.com/p3nGu1nZz/atproto
📚 Docs: [Link to docs]

Would love to hear your feedback and ideas for new features! Also happy to help with integration if anyone wants to try it out.
```

### MCP Community Discord

```
New MCP server alert! 🚨

Just published @atproto/mcp-server - a Model Context Protocol server for Bluesky/AT Protocol.

**Features:**
- 34 tools for complete Bluesky interaction
- TypeScript/Node.js implementation
- JSON-RPC 2.0 over stdio
- Comprehensive documentation
- Integration guides for Claude & VS Code

**Installation:**
```
npm install -g @atproto/mcp-server
```

**Use Cases:**
- AI-powered social media automation
- Building Bluesky bots with AI
- Content management and scheduling
- Research and data collection

This is my first MCP server project - feedback and suggestions are very welcome!

GitHub: https://github.com/p3nGu1nZz/atproto
npm: https://www.npmjs.com/package/@atproto/mcp-server
```

## Dev.to Blog Post Draft

**Title:** Introducing @atproto/mcp-server: Connect AI Agents to Bluesky

**Tags:** `#ai` `#mcp` `#bluesky` `#opensource`

**Draft:**
```markdown
I'm excited to announce the release of @atproto/mcp-server, a Model Context Protocol server that enables AI agents to interact with Bluesky and the AT Protocol.

## What is it?

@atproto/mcp-server is a standards-compliant MCP server that provides 34 tools for AI agents to interact with Bluesky. It works seamlessly with Claude Desktop, VS Code Copilot, and other MCP-compatible applications.

## Why Build This?

The intersection of AI agents and decentralized social networks is fascinating. As Bluesky and AT Protocol gain traction, there's a growing need for tools that let AI systems interact with these platforms programmatically.

Traditional API integrations require custom code for each use case. MCP provides a standardized way for AI agents to discover and use tools, making integration much simpler.

## Key Features

[Continue with technical details, examples, and usage guide...]

## Installation

```bash
npm install -g @atproto/mcp-server
```

## Quick Start

[Add integration examples and code snippets...]

## Conclusion

[Wrap up with call to action and links...]

GitHub: https://github.com/p3nGu1nZz/atproto
npm: https://www.npmjs.com/package/@atproto/mcp-server
```

---

## Usage Instructions

1. **Choose the appropriate template** for your target platform
2. **Customize as needed** (add personal touches, adjust tone)
3. **Copy and paste** when ready to announce
4. **Track engagement** and respond to feedback

## Timing Suggestions

- **Bluesky:** Post immediately after npm publish (captures initial excitement)
- **Twitter/X:** Post within 1 hour (cross-platform visibility)
- **Reddit:** Post within 24 hours (allows for refined messaging)
- **Hacker News:** Post within 48 hours (after initial feedback incorporated)
- **LinkedIn:** Post within 1 week (professional context, can include early metrics)
- **Dev.to:** Write detailed blog post within 2 weeks (comprehensive guide)

## Engagement Tips

- Respond promptly to questions and feedback
- Share usage examples and success stories
- Thank early adopters and contributors
- Update posts with download numbers and adoption metrics
- Cross-link between platforms for broader reach

---

*Templates created: November 1, 2025*
*Ready to use after npm publish!*
