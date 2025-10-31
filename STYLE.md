# atproto Style Guide

This document defines the coding standards, conventions, and best practices for the atproto project. Following these guidelines ensures code consistency, maintainability, and collaboration effectiveness.

## General Principles

- **Simplicity**: Prefer simple, readable solutions over complex ones
- **Consistency**: Follow established patterns throughout the codebase
- **POSIX Compliance**: Write portable shell scripts that work across different systems
- **Security First**: Always consider security implications of code changes
- **Documentation**: Code should be self-documenting with appropriate comments

## Shell Scripting Standards

### Shebang Line

Always use the bash shebang with error handling:

```bash
#!/bin/bash
# Description of what this script does

set -e  # Exit on any error
```

### File Organization

```bash
#!/bin/bash
# Script purpose and description
# Copyright information (if applicable)

# Exit on errors
set -e

# Constants and configuration
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/atproto"
SESSION_FILE="$CONFIG_DIR/session.json"

# Source dependencies
# shellcheck source=../lib/atproto.sh
source "$LIB_DIR/atproto.sh"

# Function definitions
function_name() {
    # Function implementation
}

# Main execution
main() {
    # Main logic
}

# Script entry point
main "$@"
```

### Variable Naming

- **Global constants**: ALL_CAPS with underscores
- **Local variables**: lowercase with underscores
- **Function names**: lowercase with underscores
- **Environment variables**: ALL_CAPS following convention

```bash
# Good
CONFIG_DIR="/path/to/config"
local user_input
session_file="$CONFIG_DIR/session.json"

# Bad
configDir="/path/to/config"
UserInput=""
SESSIONFILE="$configDir/session.json"
```

### Quoting and Escaping

Always quote variables to prevent word splitting and glob expansion:

```bash
# Good
if [ -f "$config_file" ]; then
    echo "Found config: $config_file"
fi

# Bad
if [ -f $config_file ]; then
    echo Found config: $config_file
fi
```

### Error Handling

Implement proper error handling and user feedback:

```bash
# Function with error handling
validate_input() {
    local input="$1"
    
    if [ -z "$input" ]; then
        error "Input cannot be empty"
        return 1
    fi
    
    if ! echo "$input" | grep -q "^[a-zA-Z0-9._-]*$"; then
        error "Input contains invalid characters"
        return 1
    fi
    
    return 0
}

# Usage with error checking
if ! validate_input "$user_input"; then
    exit 1
fi
```

### Color Output

Use color consistently with fallback for non-interactive terminals:

```bash
# Color definitions (from lib/atproto.sh)
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    NC='\033[0m' # No Color
else
    RED=''
    GREEN=''
    YELLOW=''
    NC=''
fi

# Usage functions
error() {
    echo -e "${RED}Error:${NC} $*" >&2
}

success() {
    echo -e "${GREEN}$*${NC}"
}

warning() {
    echo -e "${YELLOW}Warning:${NC} $*" >&2
}
```

## Function Design

### Function Structure

```bash
# Function with clear purpose and documentation
# Args: $1 - user identifier, $2 - password
# Returns: 0 on success, 1 on failure
# Outputs: Success/error messages to appropriate streams
atproto_login() {
    local identifier="$1"
    local password="$2"
    
    # Input validation
    if [ -z "$identifier" ] || [ -z "$password" ]; then
        error "Both identifier and password are required"
        return 1
    fi
    
    # Function logic
    # ...
    
    return 0
}
```

### Function Naming

- Use descriptive names that clearly indicate purpose
- Prefix with module/namespace when appropriate
- Use verb-noun pattern for actions: `get_user_info`, `validate_token`
- Use boolean-style names for checks: `is_logged_in`, `has_permission`

```bash
# Good
atproto_login()
atproto_logout()
is_session_valid()
get_access_token()

# Bad
login()
do_logout()
check()
token()
```

## Code Organization

### Directory Structure

```
atproto/
├── bin/              # Executable scripts
│   └── atproto        # Main CLI entry point
├── lib/              # Library functions and modules
│   ├── atproto.sh    # AT Protocol functions
│   ├── utils.sh      # Utility functions (future)
│   └── config.sh     # Configuration management (future)
├── tests/            # Test scripts
│   ├── run_tests.sh  # Test runner
│   ├── test_*.sh     # Individual test files
│   └── fixtures/     # Test data
├── doc/              # Documentation hub
│   ├── *.md          # Core documentation (ARCHITECTURE.md, QUICKREF.md, etc.)
│   ├── sessions/     # Session summaries and work logs
│   ├── progress/     # Progress reports and milestones
│   └── examples/     # Usage examples
├── mcp-server/       # MCP server implementation
│   ├── docs/         # MCP-specific documentation
│   └── src/          # MCP server source code
├── scripts/          # Build and automation scripts
│   ├── install.sh    # Installation script
│   └── package.sh    # Packaging script (future)
└── config/           # Configuration templates
    └── default.conf  # Default configuration (future)
```

### Documentation File Organization

Files should be organized as follows:

**Project Root** (`/`): Only essential files
- Strategic/foundational docs: `README.md`, `PLAN.md`, `AGENTS.md`, `STYLE.md`, `TODO.md`
- License and build files: `LICENSE`, `Makefile`, `install.sh`, `uninstall.sh`

**`doc/` Directory**: Main documentation hub
- **Core Documentation**: Feature docs (CONFIGURATION.md, DEBUGGING.md, SECURITY.md, TESTING.md, etc.)
- **Architecture Documentation**: Design decisions and system architecture (ARCHITECTURE.md, QUICKREF.md)
- **`doc/sessions/`**: Development session summaries and work logs (SESSION_SUMMARY_*.md files)
- **`doc/progress/`**: Project tracking, milestone reports, and progress updates (PROGRESS_*.md, MILESTONE_REPORT.md, PROJECT_DASHBOARD.md)
- **`doc/examples/`**: Usage examples and tutorials (example scripts)

**`mcp-server/docs/` Directory**: MCP-specific documentation
- MCP implementation guides (MCP_INTEGRATION.md, MCP_TOOLS.md, QUICKSTART_MCP.md)
- MCP server examples and configuration documentation

### Module Organization

Each module should have:
- Clear purpose and scope
- Consistent interface
- Proper error handling
- Documentation comments

```bash
#!/bin/bash
# Module: AT Protocol Authentication
# Purpose: Handle Bluesky authentication and session management
# Dependencies: curl, grep, sed

# Module-specific constants
ATP_PDS="${ATP_PDS:-https://bsky.social}"
SESSION_FILE="$CONFIG_DIR/session.json"

# Public functions (module interface)
atproto_login() { ... }
atproto_logout() { ... }
atproto_whoami() { ... }

# Private functions (module internal)
_validate_credentials() { ... }
_save_session() { ... }
_load_session() { ... }
```

## Documentation Standards

### Inline Comments

```bash
# Good: Explain why, not what
# Create session file with restrictive permissions to protect tokens
chmod 600 "$SESSION_FILE"

# Check if we're running in interactive mode for password prompt
if [ -t 0 ]; then
    read -r -s -p "$prompt" value
fi

# Bad: State the obvious
# Set file permissions to 600
chmod 600 "$SESSION_FILE"

# Read password
read -r -s -p "$prompt" value
```

### Function Documentation

```bash
# Login to Bluesky using AT Protocol
# 
# This function handles the complete authentication flow including
# credential validation, API communication, and session storage.
#
# Arguments:
#   $1 - identifier (handle or email)
#   $2 - password (app password recommended)
#
# Returns:
#   0 - Success, session created
#   1 - Authentication failed
#   2 - Network error
#
# Environment:
#   BLUESKY_HANDLE - Optional default handle
#   BLUESKY_PASSWORD - Optional password (use with caution)
#   ATP_PDS - AT Protocol server (default: https://bsky.social)
#
# Files:
#   Creates: $SESSION_FILE with mode 600
#
# Security:
#   - Passwords never stored persistently
#   - Session tokens stored with restrictive permissions
#   - Supports app passwords for additional security
atproto_login() {
    # Implementation...
}
```

## Testing Standards

### Test Structure

```bash
#!/bin/bash
# Test: Description of what is being tested

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Test setup
setup_test() {
    # Prepare test environment
}

# Test cleanup
cleanup_test() {
    # Clean up test artifacts
}

# Individual test functions
test_function_name() {
    # Arrange
    local expected="expected_value"
    local input="test_input"
    
    # Act
    local result
    result=$(function_under_test "$input")
    
    # Assert
    if [ "$result" != "$expected" ]; then
        echo "Test failed: expected '$expected', got '$result'"
        return 1
    fi
    
    return 0
}

# Test execution
main() {
    setup_test
    
    test_function_name || exit 1
    # More tests...
    
    cleanup_test
    echo "All tests passed"
}

main "$@"
```

### Test Naming

- Test files: `test_<component>.sh`
- Test functions: `test_<specific_behavior>`
- Use descriptive names that explain what's being tested

## Security Guidelines

### Credential Handling

```bash
# Good: Secure credential handling
read_password() {
    local prompt="$1"
    local var_name="$2"
    local value
    
    if [ -t 0 ]; then
        read -r -s -p "$prompt" value
        echo >&2  # New line after hidden input
    else
        error "Cannot read password from non-interactive terminal"
        return 1
    fi
    
    # Safe assignment without eval
    printf -v "$var_name" '%s' "$value"
}

# Bad: Insecure patterns
eval "$var_name='$value'"  # Command injection risk
echo "$password" > file    # Password in process list
```

### File Permissions

```bash
# Create files with appropriate permissions
touch "$SESSION_FILE"
chmod 600 "$SESSION_FILE"  # Owner read/write only

# Or use umask
(
    umask 077  # Restrictive umask for this subshell
    echo "$session_data" > "$SESSION_FILE"
)
```

### Input Validation

```bash
validate_handle() {
    local handle="$1"
    
    # Check format
    if ! echo "$handle" | grep -q '^[a-zA-Z0-9][a-zA-Z0-9.-]*[a-zA-Z0-9]$'; then
        error "Invalid handle format"
        return 1
    fi
    
    # Check length
    if [ ${#handle} -gt 253 ]; then
        error "Handle too long"
        return 1
    fi
    
    return 0
}
```

## Performance Guidelines

### Efficient Patterns

```bash
# Good: Use built-in string operations
filename="${path##*/}"        # basename
directory="${path%/*}"        # dirname
extension="${filename##*.}"   # file extension

# Good: Minimize external commands
if [ -n "$variable" ]; then   # Check if variable is non-empty
if [ -z "$variable" ]; then   # Check if variable is empty

# Bad: Unnecessary external commands
filename=$(basename "$path")
if [ "$(echo -n "$variable" | wc -c)" -gt 0 ]; then
```

### Resource Management

```bash
# Use subshells for temporary environment changes
(
    cd "$temp_directory"
    # Work in temp directory
    # Automatically returns to original directory
)

# Clean up temporary files
cleanup() {
    rm -f "$temp_file"
    rmdir "$temp_dir" 2>/dev/null || true
}
trap cleanup EXIT
```

## Compatibility and Portability

### POSIX Compliance

```bash
# Good: POSIX compliant
command -v curl >/dev/null 2>&1 || {
    error "curl is required but not installed"
    exit 1
}

# Good: Portable parameter expansion
default_value="${VAR:-default}"

# Bad: Bash-specific features in portable code
if [[ "$string" =~ pattern ]]; then  # Use in bash-specific code only
```

### Environment Considerations

```bash
# Handle different operating systems
case "$(uname -s)" in
    Linux*)     OS="Linux";;
    Darwin*)    OS="Mac";;
    CYGWIN*)    OS="Cygwin";;
    MINGW*)     OS="MinGw";;
    *)          OS="Unknown";;
esac

# Use appropriate config directories
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/atproto"
```

## Documentation Organization Guidelines

### When Creating New Documentation

Follow these guidelines to maintain a clean, organized documentation structure:

#### Session Summaries & Work Logs
**Location**: `doc/sessions/`
**Pattern**: `SESSION_SUMMARY_YYYY-MM-DD*.md` or `WORK_LOG_*.md`
**Purpose**: Record development sessions, code review notes, decision logs
**Retention**: Archive old sessions periodically

*Examples*:
- `doc/sessions/SESSION_SUMMARY_2025-10-28.md`
- `doc/sessions/SESSION_SUMMARY_2025-10-28_CONFIG.md`
- `doc/sessions/WORK_LOG_feature-auth.md`

#### Progress Reports & Milestones
**Location**: `doc/progress/`
**Pattern**: `PROGRESS_YYYY-MM-DD.md`, `MILESTONE_*.md`, `PROJECT_DASHBOARD.md`
**Purpose**: Track project evolution, milestones, metrics, and status updates
**Retention**: Keep recent reports; archive quarterly summaries

*Examples*:
- `doc/progress/PROGRESS_2025-10-28.md`
- `doc/progress/MILESTONE_REPORT.md`
- `doc/progress/PROJECT_DASHBOARD.md`

#### Feature & Implementation Documentation
**Location**: `doc/`
**Pattern**: Feature name in uppercase (ENCRYPTION.md, DEBUG_MODE.md, etc.)
**Purpose**: Document features, configuration, testing, security, packaging
**Retention**: Permanent - update as features evolve

*Examples*:
- `doc/CONFIGURATION.md` - User configuration guide
- `doc/ENCRYPTION.md` - Encryption implementation details
- `doc/DEBUG_MODE.md` - Debugging guide
- `doc/SECURITY.md` - Security guidelines
- `doc/TESTING.md` - Testing procedures

#### MCP-Specific Documentation
**Location**: `mcp-server/docs/`
**Pattern**: MCP-focused implementation and integration guides
**Purpose**: MCP server setup, tools, integration patterns
**Retention**: Permanent - update as MCP features evolve

*Examples*:
- `mcp-server/docs/MCP_TOOLS.md` - Available MCP tools
- `mcp-server/docs/MCP_INTEGRATION.md` - Integration patterns
- `mcp-server/docs/QUICKSTART_MCP.md` - MCP quickstart guide

#### Root-Level Strategic Documents
**Location**: Project root (`/`)
**Files**: `README.md`, `PLAN.md`, `AGENTS.md`, `STYLE.md`, `TODO.md`
**Purpose**: High-level project information and strategy
**Never move these**: They're referenced externally and are foundational

### File Naming Conventions for Documentation

- **Session summaries**: `SESSION_SUMMARY_YYYY-MM-DD[_TOPIC].md`
- **Progress reports**: `PROGRESS_YYYY-MM-DD.md` or `MILESTONE_*.md`
- **Feature docs**: `FEATURE_NAME_IN_CAPS.md`
- **Guides**: `SUBJECT_GUIDE.md` or `HOW_TO_SUBJECT.md`

### Before Adding New Markdown Files

Ask yourself:
1. **Is this a strategic document?** → Keep at project root (README, PLAN, etc.)
2. **Is this a session/work log?** → Move to `doc/sessions/`
3. **Is this a progress/milestone report?** → Move to `doc/progress/`
4. **Is this a feature/implementation guide?** → Keep in `doc/`
5. **Is this MCP-specific?** → Move to `mcp-server/docs/`

## Git Commit Standards

### Commit Message Format

```
type(scope): brief description

Detailed explanation if needed.

- List specific changes
- Include breaking changes
- Reference issues: Fixes #123
```

### Commit Types

- `feat`: New features
- `fix`: Bug fixes
- `docs`: Documentation changes
- `style`: Code style changes (no logic changes)
- `refactor`: Code refactoring
- `test`: Test additions or modifications
- `chore`: Build process or auxiliary tool changes

### Examples

```
feat(auth): add support for custom AT Protocol servers

Allow users to specify custom PDS endpoints via ATP_PDS environment
variable for development and testing purposes.

- Add validation for custom endpoints
- Update documentation with examples
- Add tests for custom server scenarios

Fixes #45
```

## Code Review Checklist

### Functionality
- [ ] Code works as intended
- [ ] Edge cases are handled
- [ ] Error conditions are properly managed
- [ ] Input validation is present

### Style and Standards
- [ ] Follows project naming conventions
- [ ] Proper error handling patterns
- [ ] Appropriate use of colors and output
- [ ] Consistent with existing code style

### Security
- [ ] No credential exposure
- [ ] Proper file permissions
- [ ] Input sanitization
- [ ] No command injection vulnerabilities

### Testing
- [ ] Tests are included for new functionality
- [ ] Tests cover edge cases
- [ ] All tests pass
- [ ] Test naming follows conventions

### Documentation
- [ ] Functions are documented
- [ ] Complex logic has comments
- [ ] README updated if needed
- [ ] Breaking changes documented

## Tools and Automation

### Recommended Tools

- **shellcheck**: Static analysis for shell scripts
- **shfmt**: Shell script formatter
- **bats**: Bash testing framework (future consideration)

### Pre-commit Hooks

```bash
#!/bin/bash
# .git/hooks/pre-commit

# Run shellcheck on all shell scripts
find . -name "*.sh" -exec shellcheck {} \;

# Check for common mistakes
if git diff --cached | grep -E "(TODO|FIXME|HACK)"; then
    echo "Warning: Found TODO/FIXME/HACK in staged changes"
fi

# Ensure executable scripts have proper shebang
for file in $(git diff --cached --name-only --diff-filter=ACM); do
    if [ -x "$file" ] && [ ! -f "$file" ]; then
        continue
    fi
    if [ -x "$file" ] && ! head -n1 "$file" | grep -q "^#!"; then
        echo "Error: Executable file $file missing shebang"
        exit 1
    fi
done
```

---

This style guide is a living document that evolves with the project. When in doubt, look at existing code for patterns, and don't hesitate to discuss style decisions in pull requests.

*Last updated: October 28, 2025*