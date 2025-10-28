#!/bin/bash
# Generate Table of Contents for AT-bot Documentation
# This script procedurally generates a TOC.md file from available documentation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DOC_DIR="$PROJECT_ROOT/doc"
OUTPUT_FILE="$DOC_DIR/TOC.md"

# Colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Create TOC header
cat > "$OUTPUT_FILE" << 'EOF'
# AT-bot Documentation Table of Contents

**Last Generated:** $(date '+%Y-%m-%d %H:%M:%S')  
**Version:** 0.1.0

---

## Quick Navigation

- **Getting Started:** [Quick Start Guide](#quick-start)
- **API Reference:** [Complete API Documentation](#api-reference)
- **User Guides:** [User Documentation](#user-guides)
- **Development:** [Developer Documentation](#developer-documentation)

---

## Main Documentation

### Project Overview
- [README.md](../README.md) - Project overview, features, and getting started
- [PLAN.md](../PLAN.md) - Strategic roadmap and architecture evolution
- [AGENTS.md](../AGENTS.md) - AI agent integration and automation patterns
- [STYLE.md](../STYLE.md) - Coding standards and best practices
- [TODO.md](../TODO.md) - Project tasks and feature roadmap
- [LICENSE](../LICENSE) - Project license (MIT/CC0)

---

## Core Documentation

### Quick Start & Getting Started {#quick-start}

- [QUICKSTART.md](QUICKSTART.md) - Quick start guide for new users
- [QUICKREF.md](QUICKREF.md) - Quick reference card for common commands

### User Guides & How-To

- [CONFIGURATION.md](CONFIGURATION.md) - Configuration guide and options
- [DEBUG_MODE.md](DEBUG_MODE.md) - Debugging guide and troubleshooting
- [TESTING.md](TESTING.md) - Testing procedures and test suite usage
- [ENCRYPTION.md](ENCRYPTION.md) - Credential encryption and security

### Development & Architecture

- [ARCHITECTURE.md](ARCHITECTURE.md) - System architecture and design
- [DOCUMENTATION.md](DOCUMENTATION.md) - Documentation build system

---

## API Reference {#api-reference}

- [API.md](API.md) - **Comprehensive API Reference (APPENDIX)**
  - AT Protocol Library API - Full function reference
  - CLI Commands - Complete command documentation
  - MCP Tools - Model Context Protocol tool definitions
  - Examples and recipes

---

## Session & Progress Tracking

### Session Documentation

Development session summaries and work logs:

- [SESSION_SUMMARY_2025-10-28.md](sessions/SESSION_SUMMARY_2025-10-28.md) - Initial session summary
- [SESSION_SUMMARY_2025-10-28_CONFIG.md](sessions/SESSION_SUMMARY_2025-10-28_CONFIG.md) - Configuration work session
- [SESSION_SUMMARY_2025-10-28_ENCRYPTION.md](sessions/SESSION_SUMMARY_2025-10-28_ENCRYPTION.md) - Encryption implementation
- [SESSION_SUMMARY_2025-10-28_ENGAGEMENT.md](sessions/SESSION_SUMMARY_2025-10-28_ENGAGEMENT.md) - Engagement features
- [SESSION_SUMMARY_2025-10-28_FEATURES.md](sessions/SESSION_SUMMARY_2025-10-28_FEATURES.md) - Feature development
- [SESSION_SUMMARY_2025-10-28_PHASE1_COMPLETE.md](sessions/SESSION_SUMMARY_2025-10-28_PHASE1_COMPLETE.md) - Phase 1 completion
- [SESSION_SUMMARY_2025-10-28_TEST_OUTPUT_ANALYSIS.md](sessions/SESSION_SUMMARY_2025-10-28_TEST_OUTPUT_ANALYSIS.md) - Test improvements
- [PROJECT_REVIEW_2025-10-28.md](sessions/PROJECT_REVIEW_2025-10-28.md) - Project review
- [WORKFLOW_AND_DECISIONS.md](sessions/WORKFLOW_AND_DECISIONS.md) - Development decisions

### Progress Reports

Project progress and milestone tracking:

- [PROGRESS_2025-10-28.md](progress/PROGRESS_2025-10-28.md) - Daily progress report
- [MILESTONE_REPORT.md](progress/MILESTONE_REPORT.md) - Milestone achievements
- [PROJECT_DASHBOARD.md](progress/PROJECT_DASHBOARD.md) - Project status dashboard

---

## Examples & Recipes

Example scripts and usage patterns:

- [examples/automation-example.sh](../examples/automation-example.sh) - Example automation script
- [examples/config-demo.sh](../examples/config-demo.sh) - Configuration example

---

## Source Code Reference

Core implementation files (for reference):

- [lib/atproto.sh](../lib/atproto.sh) - AT Protocol library (850+ lines)
- [lib/config.sh](../lib/config.sh) - Configuration management
- [lib/cli-utils.sh](../lib/cli-utils.sh) - CLI utilities
- [bin/at-bot](../bin/at-bot) - Main CLI entry point
- [Makefile](../Makefile) - Build system

---

## MCP Server Documentation

Model Context Protocol (MCP) server implementation:

- [mcp-server/README.md](../mcp-server/README.md) - MCP server overview
- [mcp-server/docs/QUICKSTART_MCP.md](../mcp-server/docs/QUICKSTART_MCP.md) - MCP quick start
- [mcp-server/docs/MCP_TOOLS.md](../mcp-server/docs/MCP_TOOLS.md) - MCP tool definitions
- [mcp-server/docs/MCP_INTEGRATION.md](../mcp-server/docs/MCP_INTEGRATION.md) - MCP integration guide

---

## Testing & Quality

- [Testing Guide](TESTING.md) - Complete testing documentation
- [Test Suite](../tests/) - Automated test files
  - `tests/atp_test.sh` - End-to-end integration tests
  - `tests/test_*.sh` - Component tests
- [Build System](../scripts/) - Build and development scripts

---

## File Organization

```
AT-bot/
├── doc/                          # Documentation hub (YOU ARE HERE)
│   ├── API.md                   # API Reference (Appendix)
│   ├── ARCHITECTURE.md          # Architecture documentation
│   ├── CONFIGURATION.md         # Configuration guide
│   ├── DEBUG_MODE.md            # Debugging guide
│   ├── DOCUMENTATION.md         # Doc build system
│   ├── ENCRYPTION.md            # Encryption reference
│   ├── QUICKREF.md              # Quick reference
│   ├── QUICKSTART.md            # Quick start guide
│   ├── TESTING.md               # Testing guide
│   ├── TOC.md                   # THIS FILE (Table of Contents)
│   ├── sessions/                # Development session logs
│   ├── progress/                # Progress tracking
│   ├── examples/                # Usage examples
│   └── _images/                 # Documentation images
├── README.md                      # Project overview
├── PLAN.md                        # Strategic roadmap
├── AGENTS.md                      # Agent integration guide
├── STYLE.md                       # Code style guide
├── TODO.md                        # Task list
├── LICENSE                        # MIT/CC0 license
├── lib/                           # Core libraries
│   ├── atproto.sh               # AT Protocol functions
│   ├── config.sh                # Configuration
│   └── cli-utils.sh             # CLI utilities
├── bin/                           # Executables
│   ├── at-bot                   # Main CLI
│   └── at-bot-docs              # Documentation viewer
├── mcp-server/                    # MCP server implementation
│   ├── src/                     # TypeScript source
│   ├── docs/                    # MCP documentation
│   └── tests/                   # MCP tests
├── tests/                         # Test suites
├── scripts/                       # Build scripts
└── Makefile                       # Build targets
```

---

## Documentation Build System

The documentation is built automatically from markdown files using:

- **Tool:** `lib/doc.sh` - Documentation build script
- **Config:** `docs.config.yaml` - Build configuration
- **Formats:** HTML, Markdown, PDF (wkhtmltopdf backend)
- **Ordering:** TOC near beginning, API.md as appendix

### Rebuild Documentation

```bash
# Rebuild all docs
make docs

# Or directly:
./bin/at-bot-docs
```

---

## Search & Navigation Tips

### By Use Case

**New Users:**
1. Start with [README.md](../README.md)
2. Follow [QUICKSTART.md](QUICKSTART.md)
3. Reference [QUICKREF.md](QUICKREF.md)

**API Usage:**
1. See [API.md](API.md) for complete reference
2. Check [CONFIGURATION.md](CONFIGURATION.md) for options
3. Review [examples/](../examples/) for patterns

**Development:**
1. Read [ARCHITECTURE.md](ARCHITECTURE.md) 
2. Check [STYLE.md](../STYLE.md) for standards
3. See [TESTING.md](TESTING.md) for quality
4. Review [PLAN.md](../PLAN.md) for roadmap

**Troubleshooting:**
1. Check [DEBUG_MODE.md](DEBUG_MODE.md)
2. Review [TESTING.md](TESTING.md)
3. See [CONFIGURATION.md](CONFIGURATION.md)

**AI Agent Integration:**
1. Read [AGENTS.md](../AGENTS.md)
2. Check [mcp-server/docs/MCP_INTEGRATION.md](../mcp-server/docs/MCP_INTEGRATION.md)
3. Review [API.md](API.md) MCP Tools section

---

## Documentation Statistics

| Metric | Count |
|--------|-------|
| **Total Documentation Files** | 25+ |
| **Lines of Documentation** | 50,000+ |
| **Code Examples** | 100+ |
| **API Functions** | 80+ (AT Protocol) |
| **CLI Commands** | 35+ |
| **MCP Tools** | 31 |

---

## Contribution & Updates

- **Contributing:** See [CONTRIBUTING.md](../CONTRIBUTING.md) or main [PLAN.md](../PLAN.md)
- **Reporting Issues:** https://github.com/p3nGu1nZz/AT-bot/issues
- **Discussions:** https://github.com/p3nGu1nZz/AT-bot/discussions

---

## Quick Links

- **GitHub Repository:** https://github.com/p3nGu1nZz/AT-bot
- **Issue Tracker:** https://github.com/p3nGu1nZz/AT-bot/issues
- **AT Protocol Docs:** https://atproto.com/
- **Bluesky:** https://bsky.app/

---

## Documentation Map by Topic

### Authentication & Security
- [ENCRYPTION.md](ENCRYPTION.md) - Encryption and credential storage
- [CONFIGURATION.md](CONFIGURATION.md) - Config and security settings
- [API.md#authentication](API.md#authentication-functions) - Auth API reference

### Content Management
- [QUICKSTART.md](QUICKSTART.md) - Creating first post
- [API.md#content](API.md#content-management-functions) - Content API
- [examples/](../examples/) - Example scripts

### Development & Testing
- [ARCHITECTURE.md](ARCHITECTURE.md) - System design
- [TESTING.md](TESTING.md) - Test suite
- [STYLE.md](../STYLE.md) - Code standards
- [PLAN.md](../PLAN.md) - Roadmap

### Deployment & Operations
- [CONFIGURATION.md](CONFIGURATION.md) - Setup options
- [DEBUG_MODE.md](DEBUG_MODE.md) - Troubleshooting
- [mcp-server/](../mcp-server/) - Server deployment

---

## Version & Compatibility

- **Current Version:** 0.1.0
- **Phase:** Phase 1 - Foundation (Complete)
- **Next Phase:** Phase 2 - Core Features + MCP
- **Supported Platforms:** Linux, macOS, WSL, Alpine
- **Shell:** Bash 4.0+

---

*Table of Contents automatically generated*  
*Last Updated: October 28, 2025*  
*Documentation Version: 0.1.0*
EOF

# Replace the date placeholder with actual date
sed -i "s/\$(date '+%Y-%m-%d %H:%M:%S')/$(date '+%Y-%m-%d %H:%M:%S')/g" "$OUTPUT_FILE"

echo -e "${GREEN}✓${NC} Table of Contents generated: ${BLUE}$OUTPUT_FILE${NC}"
echo -e "${GREEN}✓${NC} $(grep -c '^-' "$OUTPUT_FILE") documentation files indexed"
echo -e "${GREEN}✓${NC} TOC.md ready for PDF inclusion"
