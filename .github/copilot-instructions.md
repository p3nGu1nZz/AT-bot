# AT-bot AI Coding Agent Instructions

## Project Overview
AT-bot is a POSIX-compliant CLI tool for Bluesky/AT Protocol automation. It's a bash-based tool focused on simplicity, security, and cross-platform compatibility.

**Current Phase**: Phase 1 - Foundation (v0.1.0 - v0.3.0)  
**Project Status**: See [PLAN.md](../PLAN.md) for strategic roadmap and architecture evolution  
**Agent Integration**: See [AGENTS.md](../AGENTS.md) for comprehensive automation patterns and opportunities

## Architecture & Key Patterns

### Dual-Path Library Loading
The main executable `bin/at-bot` supports both development and installed configurations:
```bash
# Development: bin/at-bot → ../lib/atproto.sh  
# Installed: /usr/local/bin/at-bot → /usr/local/lib/at-bot/atproto.sh
```
When adding features, maintain this dual-path pattern in the library detection logic.

### Session Management Pattern
- Session tokens stored in `~/.config/at-bot/session.json` (mode 600)
- Use `get_access_token()` from `lib/atproto.sh` for authenticated requests
- Never store passwords, only session tokens from AT Protocol auth flow
- Check session existence with `[ -f "$SESSION_FILE" ]` before authenticated operations

### AT Protocol Integration
- All API calls go through `api_request()` function in `lib/atproto.sh`
- AT Protocol endpoints use `/xrpc/com.atproto.server.*` format
- JSON parsing uses simple sed-based `json_get_field()` - avoid complex parsers
- PDS endpoint configurable via `ATP_PDS` env var (defaults to https://bsky.social)

## Development Workflows

### Testing Strategy
```bash
# Run all tests
make test
# or
bash tests/run_tests.sh

# Individual test files follow pattern: tests/test_*.sh
# Tests should be self-contained and exit with 0/1
```

### Installation & Deployment
```bash
# Development
./install.sh                    # Install to /usr/local
PREFIX=$HOME/.local ./install.sh # Custom location

# Make-based
make install PREFIX=/custom/path
make uninstall
```

### Adding New Commands
1. Add case in `main()` function in `bin/at-bot`
2. Implement function in `lib/atproto.sh` with `atproto_` prefix
3. Add test in `tests/test_cli_*.sh`
4. Update help text in `show_help()` function

## Code Conventions

### Error Handling
- Use `set -e` in all scripts for fail-fast behavior
- Provide user-friendly error messages via `error()` function
- Use colored output functions: `error()`, `success()`, `warning()`
- Check session file before authenticated operations

### Security Patterns
- Use `read_password()` for sensitive input (hides typing)
- Set restrictive permissions: `chmod 600 "$SESSION_FILE"`
- Support environment variables `BLUESKY_HANDLE`/`BLUESKY_PASSWORD` for automation
- Validate all user inputs before API calls

### Shell Script Best Practices
- Always quote variables: `"$variable"`
- Use `local` for function variables
- Prefer `printf -v` for safe variable assignment
- Use `$(command)` over backticks
- Include shellcheck source comments for lib imports

## Agent Integration Opportunities

### Core Agent Categories (from AGENTS.md)

#### 1. Content Creation Agents
- **Social Media Automation**: Schedule posts, curate content, handle engagement
- **Code Documentation**: Auto-generate and update documentation from code changes
- **Implementation Pattern**: Shell scripts + AT-bot CLI + AI services

#### 2. Development Workflow Agents  
- **Testing & QA**: Post test results, alert on vulnerabilities, share benchmarks
- **Release Management**: Announce releases, generate changelogs, coordinate deployments
- **Implementation Pattern**: CI/CD pipelines + AT-bot + testing frameworks

#### 3. Community Management Agents
- **Support Bot**: Answer common questions, provide guidance, collect feedback
- **Analytics & Insights**: Track metrics, identify trends, generate reports
- **Implementation Pattern**: Webhooks + AT-bot + knowledge bases

### Integration Points for New Features

When adding agent-related functionality:
- Design with automation in mind (think: how can this be used by agents?)
- Support both interactive and programmatic modes
- Ensure operations are composable (can be chained together)
- Document automation use cases alongside features
- Add batch/bulk operation support where applicable

### CLI Design for Agent Usage

Commands should support:
- Non-interactive operation (no prompts when credentials available)
- Machine-readable output (JSON, structured formats)
- Exit codes that indicate success/failure/retry
- Environment variable configuration
- Piping and composition with other tools

Example pattern for agent-friendly commands:
```bash
# Current pattern - good for CLI automation
at-bot login --handle user.bsky.social --password "$APP_PASSWORD" || exit 1
at-bot post "$(generate_content)" 2>/dev/null && notify_success || notify_failure

# Future pattern - would support batch operations
at-bot batch-post @posts.txt  # Read posts from file
at-bot schedule @schedule.json  # Schedule multiple operations
```

### Event-Driven Automation Patterns

Key integration points for agents:
- Successful deployments → announcement posts
- Test completions → result sharing
- Release events → changelog generation and posting
- Scheduled tasks → recurring operations
- Webhook triggers → reactive automation

See [AGENTS.md](../AGENTS.md) for detailed examples and best practices.

## Extension Points

### Adding AT Protocol Methods
Pattern for new XRPC endpoints:
```bash
atproto_new_feature() {
    local param="$1"
    local access_token
    access_token=$(get_access_token) || {
        error "Not logged in"
        return 1
    }
    
    local response
    response=$(api_request POST "/xrpc/com.atproto.repo.createRecord" \
        '{"collection":"app.bsky.feed.post","record":{"text":"'"$param"'"}}' \
        "$access_token")
    
    # Handle response...
}
```

### Configuration Extensions
- Respect XDG Base Directory: `${XDG_CONFIG_HOME:-$HOME/.config}/at-bot`
- Use JSON for structured config, shell variables for simple settings
- Maintain backward compatibility with existing session format

## Documentation Organization

### File Placement Guidelines

When creating or updating documentation, ensure files are placed in the correct location:

**Strategic/Root-Level Documents** (Keep at project root)
- `README.md` - Project overview and getting started
- `PLAN.md` - Strategic roadmap and vision
- `AGENTS.md` - AI agent integration and automation patterns
- `STYLE.md` - Code style and standards (this file)
- `TODO.md` - Project tasks and feature backlog

**Session Summaries** (Place in `doc/sessions/`)
- Development session logs and notes
- Code review summaries
- Decision documentation from work sessions
- Pattern: `SESSION_SUMMARY_YYYY-MM-DD[_TOPIC].md`

**Progress Reports** (Place in `doc/progress/`)
- Project progress updates
- Milestone reports
- Project dashboard and metrics
- Pattern: `PROGRESS_YYYY-MM-DD.md` or `MILESTONE_*.md`

**Feature & Implementation Documentation** (Place in `doc/`)
- Feature guides (CONFIGURATION.md, ENCRYPTION.md, DEBUG_MODE.md, etc.)
- How-to guides and tutorials
- Security and testing documentation
- Architecture and design documents

**MCP-Specific Documentation** (Place in `mcp-server/docs/`)
- MCP server implementation guides
- MCP tool definitions and schemas
- MCP integration examples
- Pattern: `MCP_*.md` or `QUICKSTART_MCP.md`

For detailed organization guidelines, see the Documentation Organization Guidelines section in [STYLE.md](../STYLE.md).

## Code Style & Quality Standards

For detailed coding standards, refer to [STYLE.md](../STYLE.md). Key requirements:

### Naming Conventions
- **Global constants**: `ALL_CAPS_WITH_UNDERSCORES`
- **Local variables**: `lowercase_with_underscores`
- **Function names**: `lowercase_with_underscores`
- **AT Protocol functions**: `atproto_<function_name>` prefix
- **Boolean checks**: `is_<condition>` or `has_<property>`

### Function Documentation
All functions should include documentation comments:
```bash
# Brief description of what the function does
# 
# Detailed explanation if needed
#
# Arguments:
#   $1 - description of first argument
#   $2 - description of second argument
#
# Returns:
#   0 - Success
#   1 - Specific failure condition
#
# Environment:
#   REQUIRED_VAR - Description of required environment variable
#
# Files:
#   Creates: Path to files created
#   Uses: Path to files used
```

### Error Handling Patterns
```bash
# Pattern 1: Simple error check
if ! validate_input "$user_input"; then
    error "Validation failed"
    return 1
fi

# Pattern 2: Command substitution with error handling
local access_token
access_token=$(get_access_token) || {
    error "Not logged in"
    return 1
}

# Pattern 3: Check required file exists
if [ ! -f "$SESSION_FILE" ]; then
    error "Session file not found"
    return 1
fi
```

### Testing Standards
- Test files: `tests/test_<component>.sh`
- Test functions: `test_<specific_behavior>`
- Use `exit 0` for success, `exit 1` for failure
- Include descriptive test names that explain what's being tested
- See `tests/test_*.sh` files for examples

## Implementation Workflows

### When to Add New Features

#### New AT Protocol Command
1. Add function to `lib/atproto.sh` with `atproto_` prefix
2. Add case statement to `main()` in `bin/at-bot`
3. Update `show_help()` with new command documentation
4. Create test file `tests/test_<command>.sh`
5. Update `README.md` and [TODO.md](../TODO.md) if applicable
6. Reference relevant sections in [AGENTS.md](../AGENTS.md) for automation use cases

#### New Agent Feature
1. Design with automation in mind (review [AGENTS.md](../AGENTS.md) patterns)
2. Implement core functionality in library module
3. Add CLI command or enhance existing command
4. Add tests for agent-specific scenarios
5. Document in [AGENTS.md](../AGENTS.md) if adding new automation patterns
6. Ensure non-interactive operation and structured output support

#### New Automation Pattern
1. Document in [AGENTS.md](../AGENTS.md) with practical examples
2. Create example shell scripts in appropriate section
3. Include security and ethical considerations
4. Add reference to implementation in core code
5. Consider creating integration tests

## Code Review Checklist

### Functionality
- [ ] Works as intended
- [ ] Edge cases handled
- [ ] Error conditions managed
- [ ] Input validation present

### Style and Standards
- [ ] Follows [STYLE.md](../STYLE.md) naming conventions
- [ ] Proper error handling patterns (see above)
- [ ] Appropriate use of color functions
- [ ] Consistent with existing code style

### Security (Critical)
- [ ] No credential exposure
- [ ] Proper file permissions (session files: 600)
- [ ] Input sanitization
- [ ] No command injection vulnerabilities
- [ ] Safe variable assignment (using `printf -v`)

### Agent Readiness
- [ ] Non-interactive mode works with environment variables
- [ ] Structured output for scripting (JSON, exit codes)
- [ ] Operations are composable and can be chained
- [ ] Documented for automation use cases
- [ ] Batch/bulk operations considered

### Testing
- [ ] Tests included for new functionality
- [ ] Tests cover edge cases
- [ ] All tests pass: `make test`
- [ ] Test naming follows conventions

### Documentation
- [ ] Functions documented with comments
- [ ] Complex logic has explanatory comments
- [ ] Help text updated
- [ ] [AGENTS.md](../AGENTS.md) updated if automation-related
- [ ] [TODO.md](../TODO.md) updated if task-related
- [ ] Breaking changes documented

## Critical Files & Documentation
- `bin/at-bot`: Main CLI dispatcher and help system
- `lib/atproto.sh`: Core AT Protocol implementation and utilities
- `tests/run_tests.sh`: Test runner with colored output
- `Makefile`: Installation targets and development workflows
- `PLAN.md`: Strategic roadmap and architecture decisions
- `STYLE.md`: Shell scripting standards and code conventions
- `AGENTS.md`: Comprehensive automation and AI integration guide
- `TODO.md`: Project task checklist and feature roadmap
- `.github/copilot-instructions.md`: AI agent coding guidelines (this file)