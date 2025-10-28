#!/bin/bash
# AT-bot Test Runner
# Convenient wrapper for running AT-bot automated tests
# Usage: ./scripts/test-atp.sh [OPTIONS]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TEST_SCRIPT="$PROJECT_ROOT/tests/atp_test.sh"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Verify test script exists
if [ ! -f "$TEST_SCRIPT" ]; then
    echo -e "${RED}✗ Error:${NC} Test script not found: $TEST_SCRIPT" >&2
    exit 1
fi

# Verify test script is executable
if [ ! -x "$TEST_SCRIPT" ]; then
    chmod +x "$TEST_SCRIPT"
fi

# Show help
show_help() {
    cat << 'EOF'
AT-bot Test Runner

USAGE
  ./scripts/test-atp.sh [OPTIONS]

DESCRIPTION
  Runs the AT-bot automated end-to-end integration test suite.
  Tests authentication, content, profiles, search, configuration, and diagnostics.

OPTIONS
  -h, --help      Show this help message
  -v, --verbose   Show verbose test output
  -q, --quiet     Suppress non-essential output

EXAMPLES
  # Run all tests (interactive or with saved credentials)
  ./scripts/test-atp.sh

  # Run tests with verbose output
  ./scripts/test-atp.sh --verbose

  # Run tests quietly (CI/CD mode)
  ./scripts/test-atp.sh --quiet

FEATURES
  • Automatic authentication (interactive login or saved credentials)
  • Credential saving for automated test runs
  • Sequential API testing (6 test categories)
  • Comprehensive diagnostics
  • CI/CD ready with proper exit codes

TEST CATEGORIES
  1. 🔐 Authentication    - Verify current user identity
  2. 📝 Content           - Read timeline/feed
  3. 👤 Profile           - View user profiles
  4. 🔍 Search            - Search posts and content
  5. ⚙️  Configuration     - View system configuration
  6. 🧪 Diagnostics       - System health checks

EXIT CODES
  0  - All tests passed
  1  - One or more tests failed

NOTES
  - First run requires interactive authentication
  - Credentials are saved (mode 600) for subsequent runs
  - Set BLUESKY_HANDLE and BLUESKY_PASSWORD environment variables
    to skip interactive login

SEE ALSO
  - tests/atp_test.sh - Automated test suite
  - doc/TESTING_GUIDE.md - Comprehensive testing documentation
  - make test-e2e - Alternative: run via Makefile

EOF
}

# Parse arguments
ARGS=()
while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--verbose)
            ARGS+=("--verbose")
            shift
            ;;
        -q|--quiet)
            ARGS+=("--quiet")
            shift
            ;;
        *)
            echo -e "${RED}✗ Error:${NC} Unknown option: $1" >&2
            show_help
            exit 1
            ;;
    esac
done

# Run tests
echo -e "${CYAN}Running AT-bot Tests...${NC}"
echo ""

exec "$TEST_SCRIPT" "${ARGS[@]}"
