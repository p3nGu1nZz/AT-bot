# AT-bot Architecture

This document describes the overall architecture of AT-bot, including both the CLI interface and the MCP server interface.

## Project Architecture Overview

AT-bot is designed as a dual-interface system that serves both traditional CLI users and AI agents through the Model Context Protocol (MCP).

### High-Level Architecture

```
┌──────────────────────────────────────────────────────┐
│              User Interfaces                          │
├─────────────────────┬────────────────────────────────┤
│   CLI Users         │   MCP-based Agents            │
│   (at-bot cmd)      │   (AI assistants, bots)       │
└─────────┬───────────┴──────────────┬─────────────────┘
          │                          │
          │ Shell / TTY              │ JSON-RPC 2.0
          │ Traditional UX           │ Structured data
          │                          │
          ▼                          ▼
┌─────────────────────────────────────────────────────┐
│         Unified Interface Layer                      │
├─────────────────────────────────────────────────────┤
│  bin/at-bot (CLI)  |  mcp-server (MCP wrapper)      │
│  Entry point       |  Tool definitions & routing    │
└─────────────┬───────────────────┬───────────────────┘
              │                   │
              └─────────┬─────────┘
                        │
                        ▼
┌──────────────────────────────────────────────────────┐
│       Core Library Layer                             │
├──────────────────────────────────────────────────────┤
│  lib/atproto.sh                                      │
│  - Authentication & session management              │
│  - AT Protocol API communication                    │
│  - Data parsing and validation                      │
│  - Error handling and logging                       │
│  - Utility functions                                │
└──────────────┬───────────────────────────────────────┘
               │
               ▼
┌──────────────────────────────────────────────────────┐
│      AT Protocol / Bluesky Network                   │
└──────────────────────────────────────────────────────┘
```

## Layer Descriptions

### 1. User Interface Layer

#### CLI Interface (`bin/at-bot`)
- **Purpose**: Provides traditional command-line interface for users and scripts
- **Interaction**: User runs commands directly in terminal
- **Output**: Colored text output, user-friendly messages
- **Protocol**: Shell commands and arguments
- **Examples**: `at-bot login`, `at-bot post "Hello"`, `at-bot whoami`

#### MCP Server Interface (`mcp-server`)
- **Purpose**: Provides standardized JSON-RPC interface for AI agents
- **Interaction**: Agents send JSON-RPC requests over stdio
- **Output**: Structured JSON responses
- **Protocol**: JSON-RPC 2.0 over stdio (Model Context Protocol)
- **Examples**: Tool calls like `auth_login`, `post_create`, `feed_read`

### 2. Core Library Layer (`lib/atproto.sh`)

The core library provides all AT Protocol functionality:

#### Authentication Module
- `atproto_login()` - Authenticate with Bluesky
- `atproto_logout()` - Clear session
- `atproto_whoami()` - Get current user
- `get_access_token()` - Retrieve session token

#### API Communication
- `api_request()` - Make AT Protocol API calls
- Request formatting and parameter handling
- Response validation and error handling
- Automatic retry logic for transient failures

#### Data Handling
- `json_get_field()` - Parse JSON responses
- Session persistence and loading
- Configuration management
- Error handling and logging

#### Utility Functions
- File and path operations
- String manipulation
- Environment variable handling
- Directory and permission management

### 3. Network Layer

Direct communication with Bluesky's AT Protocol:
- HTTPS connections to AT Protocol PDS
- Configurable endpoint via `ATP_PDS` environment variable
- Bearer token authentication
- JSON request/response format

## Component Responsibilities

### CLI (`bin/at-bot`)
- Parse command-line arguments
- Invoke appropriate functions from `lib/atproto.sh`
- Format and display output for terminal
- Handle user interactions (prompts, confirmations)
- Maintain backward compatibility

### MCP Server (`mcp-server`)
- Listen for JSON-RPC 2.0 requests on stdin
- Validate tool requests and parameters
- Call appropriate functions from `lib/atproto.sh`
- Format responses as JSON-RPC success/error
- Send responses to stdout
- Manage concurrent requests if applicable

### Core Library (`lib/atproto.sh`)
- Implement all AT Protocol operations
- Handle authentication and session management
- Manage API communication
- Provide reusable functions for both CLI and MCP
- Abstract away implementation details
- Handle errors and edge cases

## Data Flow Examples

### Example 1: CLI Login Flow

```
User: $ at-bot login

bin/at-bot
  │
  ├─→ Parse arguments
  ├─→ Call: atproto_login()
  │   │
  │   ▼ lib/atproto.sh
  │   ├─→ Prompt for handle
  │   ├─→ Prompt for password
  │   ├─→ Call: api_request() with /xrpc/com.atproto.server.createSession
  │   │   │
  │   │   ▼ Network
  │   │   └─→ Bluesky API
  │   │
  │   ├─→ Parse response
  │   ├─→ Save session to ~/.config/at-bot/session.json
  │   └─→ Return success
  │
  └─→ Display success message
      "Successfully logged in as: user.bsky.social"
```

### Example 2: MCP Tool Call Flow

```
Agent (via MCP): auth_login {handle, password}

mcp-server (stdin)
  │
  ├─→ Parse JSON-RPC request
  ├─→ Validate request
  ├─→ Call: atproto_login(handle, password)
  │   │
  │   ▼ lib/atproto.sh
  │   ├─→ Validate credentials
  │   ├─→ Call: api_request() with /xrpc/com.atproto.server.createSession
  │   │   │
  │   │   ▼ Network
  │   │   └─→ Bluesky API
  │   │
  │   ├─→ Parse response
  │   ├─→ Save session
  │   └─→ Return {success: true, handle, did}
  │
  └─→ Send JSON-RPC success response (stdout)
      {
        "jsonrpc": "2.0",
        "result": {"success": true, "handle": "user.bsky.social", "did": "did:plc:..."},
        "id": 1
      }
```

### Example 3: Creating a Post

```
CLI: $ at-bot post "Hello Bluesky!"
OR
MCP: post_create {text: "Hello Bluesky!"}

lib/atproto.sh (shared)
  │
  ├─→ Check authentication
  ├─→ Get access token from session
  ├─→ Call: api_request() with /xrpc/com.atproto.repo.createRecord
  │   │
  │   ▼ Network
  │   └─→ Bluesky API
  │
  ├─→ Parse response
  ├─→ Return {success: true, uri}
  │
  └─→ Back to caller (CLI or MCP)
      
      If CLI: Display: "Post created: {uri}"
      If MCP: Return JSON response
```

## Module Organization

### Core Library Modules

```
lib/
├── atproto.sh           # Main module with core functions
├── auth.sh              # Authentication (future refactor)
├── api.sh               # API communication (future refactor)
├── social.sh            # Social operations (future refactor)
├── content.sh           # Content operations (future refactor)
└── utils.sh             # Utility functions (future refactor)
```

### CLI Structure

```
bin/
├── at-bot               # Main CLI entry point
├── at-bot-lib           # CLI library functions (future)
└── commands/            # Command implementations (future)
    ├── login.sh
    ├── post.sh
    ├── feed.sh
    └── ...
```

### MCP Server Structure

```
mcp-server/             # MCP server implementation
├── server.py           # Main MCP server (or Go/Node.js equivalent)
├── tools/              # Tool definitions
│   ├── auth.py
│   ├── content.py
│   ├── feed.py
│   └── profile.py
├── wrapper.sh          # Bash wrapper for core library
└── tests/
    └── test_mcp_tools.py
```

## Integration Points

### CLI ↔ Core Library
- CLI calls functions from `lib/atproto.sh`
- CLI handles user interaction and formatting
- Core library handles all business logic
- Clean separation of concerns

### MCP Server ↔ Core Library
- MCP server wraps functions from `lib/atproto.sh`
- MCP server formats responses as JSON
- MCP server implements tool discovery
- Shared logic, different interface

### Environment Variables

Shared configuration:
```bash
ATP_PDS              # AT Protocol PDS endpoint
XDG_CONFIG_HOME      # Config directory location
BLUESKY_HANDLE       # Default handle (automation)
BLUESKY_PASSWORD     # Default password (automation only)
```

## Error Handling

### CLI Errors
- User-friendly error messages
- Colored output (red for errors)
- Exit codes (0 = success, 1 = failure, etc.)
- Suggestions for common issues

### MCP Errors
- JSON-RPC error responses
- Structured error information
- Error codes and descriptions
- Proper HTTP-like semantics

## Security Considerations

### Authentication
- Tokens stored locally with restricted permissions (600)
- Passwords never persisted
- Support for app passwords
- Session expiration handling

### Input Validation
- All user inputs validated before API calls
- Prevention of injection attacks
- Sanitization of special characters
- Type checking and bounds checking

### Network Security
- HTTPS-only communication
- Certificate validation
- Timeout handling
- Rate limit respect

## Performance Considerations

### Caching
- Session caching to avoid re-authentication
- Optional response caching for frequently accessed data
- Configuration caching

### Efficiency
- Minimal external dependencies
- Shell script optimization
- Parallel request handling (for MCP server)
- Connection pooling (future enhancement)

### Scalability
- Stateless CLI operations (except for session)
- MCP server can handle multiple concurrent requests
- No persistent storage except session files
- Lightweight subprocess model

## Future Enhancements

### Module Refactoring
- Split `lib/atproto.sh` into focused modules
- Create reusable utility library
- Establish internal API boundaries

### MCP Server Improvements
- Implement batch operation support
- Add webhook handling for real-time events
- Implement caching strategies
- Add monitoring and telemetry

### Performance
- Optimize JSON parsing
- Implement connection pooling
- Add request batching
- Profile and optimize hot paths

### Features
- Support for custom AT Protocol servers
- Advanced authentication flows
- Media handling and uploads
- Search and filtering capabilities

---

*Last updated: October 28, 2025*  
*See PLAN.md for implementation timeline and AGENTS.md for agent integration guide.*
