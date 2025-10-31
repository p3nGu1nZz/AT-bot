# Agents and Automation for atproto

This document outlines how AI agents and automated systems can enhance the atproto project through MCP (Model Context Protocol) integration, enabling sophisticated agentic workflows and collaborative development patterns.

**Core Concept**: atproto exposes AT Protocol/Bluesky capabilities through both a CLI interface and an MCP server, allowing agents to seamlessly interact with Bluesky without parsing shell output or managing sessions manually.

**📌 Quick Links:**
- [PLAN.md](PLAN.md) - Strategic roadmap with MCP integration timeline
- [STYLE.md](STYLE.md) - Coding standards and best practices
- [TODO.md](TODO.md) - Project tasks and MCP-specific features
- [.github/copilot-instructions.md](.github/copilot-instructions.md) - AI agent coding guidelines

## Overview

atproto serves as a foundational infrastructure layer for AT Protocol interactions. The project provides two primary interfaces:

1. **CLI Interface** (`atproto`): Direct command-line access for users and scripts
2. **MCP Server Interface** (`atproto mcp-server`): Standardized JSON-RPC interface for AI agents

This document explores opportunities for integrating intelligent agents through MCP, enabling next-generation automation workflows where agents collaborate with Bluesky as a native communication and coordination platform.

## AI Agent Integration Opportunities

### 1. Content Creation Agents

**Social Media Automation Agent**
- **Purpose**: Automate posting schedules, content curation, and engagement
- **Implementation**: Shell scripts + atproto for authentication + AI for content generation
- **Use Cases**:
  - Scheduled posting of project updates
  - Automated responses to common questions
  - Content summarization and sharing

**Code Documentation Agent**
- **Purpose**: Automatically generate and update project documentation
- **Implementation**: Git hooks + atproto + documentation AI
- **Use Cases**:
  - Auto-update README based on code changes
  - Generate API documentation
  - Create release notes from commit messages

### 2. Development Workflow Agents

**Testing and Quality Assurance Agent**
- **Purpose**: Continuous integration with social reporting
- **Implementation**: CI/CD pipeline + atproto + testing frameworks
- **Use Cases**:
  - Post test results to Bluesky
  - Alert about security vulnerabilities
  - Share performance benchmarks

**Release Management Agent**
- **Purpose**: Automate release processes and announcements
- **Implementation**: GitHub Actions + atproto + version management
- **Use Cases**:
  - Announce new releases on Bluesky
  - Generate changelog summaries
  - Coordinate cross-platform releases

### 3. Community Management Agents

**Support Bot Agent**
- **Purpose**: Provide automated support and guidance
- **Implementation**: Webhook listener + atproto + knowledge base
- **Use Cases**:
  - Answer common installation questions
  - Direct users to relevant documentation
  - Collect feedback and feature requests

**Analytics and Insights Agent**
- **Purpose**: Monitor project metrics and community engagement
- **Implementation**: Data collection + atproto + analytics AI
- **Use Cases**:
  - Track adoption metrics
  - Identify trending topics
  - Generate community health reports

## Automated Workflow Patterns

### 1. Event-Driven Automation

```bash
# Example: Post on successful deployment
#!/bin/bash
# deploy-success-hook.sh

source /usr/local/lib/atproto/atproto.sh

if deployment_successful; then
    post_content="✅ atproto v$(get_version) deployed successfully! 
    
Features:
- Enhanced AT Protocol support
- Improved error handling
- New authentication flow

#ATProtocol #OpenSource #CLI"
    
    atproto post "$post_content"
fi
```

### 2. Scheduled Automation

```bash
# Example: Weekly project status updates
#!/bin/bash
# weekly-status.sh

# Generate metrics
COMMITS=$(git rev-list --count HEAD ^HEAD~7)
ISSUES_CLOSED=$(gh issue list --state closed --search "closed:>=7days" --json number | jq length)
NEW_CONTRIBUTORS=$(git shortlog -sn HEAD~7..HEAD | wc -l)

STATUS="📊 Weekly atproto Update:
• $COMMITS commits this week
• $ISSUES_CLOSED issues resolved
• $NEW_CONTRIBUTORS contributors active

Thank you to our amazing community! 🙏

#WeeklyUpdate #OpenSource"

atproto post "$STATUS"
```

### 3. Collaborative Development Patterns

**Agent-Assisted Code Review**
- Pre-commit hooks that run security checks
- Automated code quality assessments
- Style guide enforcement
- Documentation completeness checks

**Community Feedback Loop**
- Monitor mentions and replies on Bluesky
- Aggregate feature requests
- Track user sentiment
- Generate monthly community reports

## MCP Server Integration

### What is MCP (Model Context Protocol)?

MCP is an open protocol for connecting AI models and agents to data and tools. It uses JSON-RPC 2.0 over stdio, making it language-agnostic and lightweight. atproto's MCP server exposes Bluesky/AT Protocol capabilities as standardized tools.

**Key Benefits:**
- **Standardized Interface**: Agents use the same protocol regardless of underlying implementation
- **Discoverable Tools**: Agents can discover available capabilities automatically
- **Composable**: Tools can be combined and chained by agents
- **Secure**: Authentication and permission management built-in
- **Extensible**: New tools can be added without modifying the protocol

### MCP Tools for atproto

The atproto MCP server exposes tools organized by category:

**Authentication Tools**
- `auth_login` - Authenticate user
- `auth_logout` - Clear session
- `auth_whoami` - Get current user info
- `auth_is_authenticated` - Check authentication status

**Content Tools**
- `post_create` - Create a new post/bleet
- `post_reply` - Reply to existing post
- `post_like` - Like a post
- `post_repost` - Repost content
- `post_delete` - Delete a post

**Feed Tools**
- `feed_read` - Read user feed
- `feed_search` - Search posts
- `feed_timeline` - Get timeline
- `feed_notifications` - Get notifications

**Profile Tools**
- `profile_get` - Get user profile
- `profile_follow` - Follow user
- `profile_unfollow` - Unfollow user
- `profile_block` - Block user
- `profile_unblock` - Unblock user

**Batch Operations** (Future)
- `batch_post` - Post multiple items
- `batch_follow` - Follow multiple users
- `batch_schedule` - Schedule operations

### MCP Configuration

```json
{
  "mcpServers": {
    "atproto": {
      "command": "atproto",
      "args": ["mcp-server"],
      "args": ["--config", "~/.config/atproto/mcp.json"],
      "env": {
        "ATP_PDS": "https://bsky.social"
      }
    }
  }
}
```

### MCP Tool Schema Example

```json
{
  "name": "post_create",
  "description": "Create a new post on Bluesky",
  "inputSchema": {
    "type": "object",
    "properties": {
      "text": {
        "type": "string",
        "description": "The post content"
      },
      "reply_to": {
        "type": "string",
        "description": "Optional post URI to reply to"
      },
      "attachments": {
        "type": "array",
        "description": "Optional media attachments"
      }
    },
    "required": ["text"]
  }
}
```

For seamless agent integration, commands should support:

**Non-Interactive Operation**
```bash
# Environment variables for credentials (development/testing only)
BLUESKY_HANDLE="bot.bsky.social"
BLUESKY_PASSWORD="$APP_PASSWORD"
atproto login

# Commands with exit codes for automation
atproto whoami && echo "Logged in successfully" || echo "Login failed"
```

**Structured Output**
```bash
# Machine-readable JSON output (future enhancement)
atproto whoami --format json
# Output: {"handle":"user.bsky.social","did":"did:plc:...","status":"authenticated"}

# Exit codes for scripting
atproto check-session
# Returns: 0 if logged in, 1 if not, 2 if session expired
```

**Composable Operations**
```bash
# Chain multiple commands
message=$(generate_daily_report)
atproto post "$message" && \
  atproto follow "@user.bsky.social" && \
  log_success || log_failure
```

**Batch/Bulk Operations** (Future)
```bash
# Read from files
atproto batch-post @daily-posts.txt
atproto batch-follow @followers-list.txt
atproto schedule @weekly-schedule.json
```

See [.github/copilot-instructions.md](.github/copilot-instructions.md) for implementation details.

## Security and Privacy Considerations

### Agent Authentication
- Separate app passwords for each agent
- Principle of least privilege
- Regular token rotation
- Audit logging for all actions

### Data Handling
- Minimize data collection
- Secure storage of credentials
- GDPR compliance for EU users
- User consent for analytics

### Rate Limiting and Ethics
- Respect AT Protocol rate limits
- Avoid spam and unwanted content
- Human oversight for all automated posts
- Clear identification of automated content

## Getting Started with Agents

### 1. Basic Agent Setup

```bash
# Create agent environment
mkdir -p ~/.config/atproto/agents
cd ~/.config/atproto/agents

# Create agent configuration
cat > config.json << EOF
{
  "name": "my-first-agent",
  "type": "scheduler",
  "schedule": "daily",
  "action": "status_update"
}
EOF

# Create agent script
cat > status_agent.sh << 'EOF'
#!/bin/bash
source /usr/local/lib/atproto/atproto.sh

# Your agent logic here
atproto post "Daily status: All systems operational! 🤖"
EOF

chmod +x status_agent.sh
```

### 2. Advanced Agent Features

- **Natural Language Processing**: Integrate with AI services for content generation
- **Image Processing**: Generate visual content (charts, diagrams, memes)
- **Multi-platform Integration**: Cross-post to multiple social networks
- **Learning Capabilities**: Adapt behavior based on engagement metrics

## Best Practices

### Development
1. **Modular Design**: Create small, focused agent scripts
2. **Error Handling**: Implement robust error recovery
3. **Logging**: Track agent activities and performance
4. **Testing**: Automated tests for agent behavior

### Deployment
1. **Gradual Rollout**: Test agents with limited scope first
2. **Monitoring**: Real-time monitoring of agent activities
3. **Rollback Plans**: Quick recovery from agent failures
4. **Documentation**: Clear documentation for each agent

### Community
1. **Transparency**: Open source agent implementations
2. **Customization**: Allow users to modify agent behavior
3. **Privacy**: Respect user privacy and preferences
4. **Feedback**: Collect and respond to community input

## Future Roadmap

### Short Term (3-6 months)
- [ ] Basic event-driven automation framework
- [ ] Simple content creation agents
- [ ] Community feedback collection system
- [ ] Documentation generation automation

### Medium Term (6-12 months)
- [ ] Advanced AI integration for content creation
- [ ] Multi-agent coordination system
- [ ] Analytics and insights dashboard
- [ ] Plugin architecture for custom agents

### Long Term (12+ months)
- [ ] Federated agent network
- [ ] Cross-platform agent marketplace
- [ ] Advanced machine learning capabilities
- [ ] Enterprise-grade agent management

## Contributing to Agent Development

We welcome contributions to the atproto agent ecosystem:

1. **Agent Scripts**: Share useful automation scripts
2. **Integration Patterns**: Document successful integration approaches
3. **Tools and Libraries**: Create reusable components for agent development
4. **Documentation**: Improve agent documentation and tutorials

See [CONTRIBUTING.md](doc/CONTRIBUTING.md) for more details on how to contribute.

### Implementation Guidelines

When implementing agent features, follow these guidelines:

1. **Code Style**: Adhere to [STYLE.md](STYLE.md) standards
   - Use proper naming conventions
   - Include comprehensive function documentation
   - Implement robust error handling
   - Follow security best practices

2. **Agent-Friendly Design**: Reference [.github/copilot-instructions.md](.github/copilot-instructions.md)
   - Support non-interactive operation
   - Provide structured output options
   - Use meaningful exit codes
   - Enable command composition

3. **Documentation**: Update relevant docs
   - Add examples to [AGENTS.md](AGENTS.md) for new automation patterns
   - Update [TODO.md](TODO.md) with completed/new items
   - Maintain [PLAN.md](PLAN.md) alignment with architecture
   - Document in copilot-instructions.md for developer guidance
   - Place documentation files in correct locations per [STYLE.md](STYLE.md#documentation-organization-guidelines)

4. **Testing**: Ensure quality
   - Write tests for new automation features
   - Test non-interactive workflows
   - Verify exit codes and output formats
   - Test security-sensitive operations

## Documentation Organization

### File Placement for Agent-Related Work

When creating documentation for agent features, use these guidelines:

**Session Summaries** → `doc/sessions/SESSION_SUMMARY_YYYY-MM-DD_TOPIC.md`
- Record agent development and testing sessions
- Document automation patterns discovered
- Note integration decisions and challenges

**Progress Reports** → `doc/progress/PROGRESS_YYYY-MM-DD.md`
- Track agent feature implementation progress
- Update project dashboard with agent metrics
- Document milestone achievements for agents

**Agent Documentation** → `doc/` (if core feature docs) or `AGENTS.md` (if pattern docs)
- Core agent framework documentation → `doc/AGENTS_FRAMEWORK.md`
- Specific agent guides → `doc/AGENT_*.md`
- Agent patterns and best practices → Update [AGENTS.md](AGENTS.md)

**MCP Server Documentation** → `mcp-server/docs/`
- MCP tool definitions → `mcp-server/docs/MCP_TOOLS.md`
- MCP server setup → `mcp-server/docs/QUICKSTART_MCP.md`
- MCP integration guides → `mcp-server/docs/MCP_INTEGRATION.md`

See [STYLE.md](STYLE.md) for comprehensive documentation organization guidelines.

## Resources

- [AT Protocol Documentation](https://atproto.com/)
- [Bluesky API Reference](https://docs.bsky.app/)
- [GitHub Actions for Automation](https://docs.github.com/actions)
- [Shell Scripting Best Practices](https://google.github.io/styleguide/shellguide.html)

---

*This document is living documentation that evolves with the project. Last updated: October 28, 2025*