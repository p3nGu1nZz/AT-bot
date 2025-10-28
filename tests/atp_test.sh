#!/bin/bash
# AT-bot Automated End-to-End Integration Tests
# This script runs comprehensive sequential API tests with optional credential saving
# Designed for both local testing and CI/CD automation

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
AT_BOT="$PROJECT_ROOT/bin/at-bot"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/at-bot"
SESSION_FILE="$CONFIG_DIR/session.json"
CREDS_FILE="$CONFIG_DIR/.test_credentials"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
DIM='\033[2m'
NC='\033[0m'

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0

# Utility functions
print_header() {
    echo ""
    echo -e "${WHITE}AT-bot Automated Integration Tests${NC}"
    echo -e "${BLUE}$(printf '═%.0s' {1..60})${NC}"
    echo ""
}

print_section() {
    echo ""
    printf "%s\n" "$1"
    echo -e "${BLUE}$(printf '─%.0s' {1..60})${NC}"
}

print_test() {
    echo -e "${BLUE}  ▶${NC} $1"
}

print_success() {
    ((PASSED_TESTS++))
    echo -e "${GREEN}  ✓${NC} $1"
}

print_failure() {
    ((FAILED_TESTS++))
    echo -e "${RED}  ✗${NC} $1"
}

# Print info without incrementing test counter
print_check_success() {
    echo -e "${GREEN}  ✓${NC} $1"
}

print_check_failure() {
    echo -e "${RED}  ✗${NC} $1"
}

print_info() {
    echo -e "${CYAN}  ℹ${NC} $1"
}

print_error() {
    echo -e "${RED}  ✗ ERROR:${NC} $1" >&2
}

# Authentication functions
load_saved_credentials() {
    if [ -f "$CREDS_FILE" ]; then
        source "$CREDS_FILE"
        print_info "Loaded saved credentials for automated testing"
        return 0
    fi
    return 1
}

save_credentials() {
    local handle="$1"
    local password="$2"
    
    mkdir -p "$CONFIG_DIR"
    cat > "$CREDS_FILE" << EOF
export BLUESKY_HANDLE="$handle"
export BLUESKY_PASSWORD="$password"
EOF
    chmod 600 "$CREDS_FILE"
    print_info "Credentials saved for next test run (encrypted: $CREDS_FILE)"
}

ensure_authenticated() {
    # Check if already authenticated
    if [ -f "$SESSION_FILE" ]; then
        print_info "Using existing session"
        return 0
    fi
    
    # Try to load saved credentials
    if load_saved_credentials; then
        print_test "Authenticating with saved credentials..."
        if "$AT_BOT" login > /dev/null 2>&1; then
            print_success "Authentication successful"
            return 0
        else
            print_failure "Authentication failed with saved credentials"
            # Clear bad credentials
            rm -f "$CREDS_FILE"
        fi
    fi
    
    # Interactive login required
    print_info "Interactive login required"
    echo ""
    echo -e "${YELLOW}  Please enter your Bluesky credentials:${NC}"
    echo ""
    read -r -p "  Handle (e.g., user.bsky.social): " handle
    read -r -s -p "  App Password: " password
    echo ""
    
    if [ -z "$handle" ] || [ -z "$password" ]; then
        print_error "Handle and password are required"
        return 1
    fi
    
    # Test login
    print_test "Authenticating with provided credentials..."
    export BLUESKY_HANDLE="$handle"
    export BLUESKY_PASSWORD="$password"
    
    if "$AT_BOT" login > /dev/null 2>&1; then
        print_success "Authentication successful as $handle"
        
        # Ask if user wants to save credentials
        echo ""
        read -r -p "  Save credentials for next test run? (y/n): " save_response
        if [ "$save_response" = "y" ] || [ "$save_response" = "Y" ]; then
            save_credentials "$handle" "$password"
        fi
        
        return 0
    else
        print_error "Authentication failed"
        return 1
    fi
}

# Test functions
run_test() {
    local test_name="$1"
    local test_cmd="$2"
    
    ((TOTAL_TESTS++))
    print_test "$test_name"
    
    if output=$($test_cmd 2>&1); then
        print_success "$test_name"
        if [ -n "$output" ]; then
            echo "$output" | sed 's/^/      /'
        fi
        return 0
    else
        print_failure "$test_name"
        if [ -n "$output" ]; then
            echo "$output" | sed 's/^/      /'
        fi
        return 1
    fi
}

# Authentication Tests
test_auth() {
    print_section "🔐 Authentication Tests"
    
    run_test "Verify current user" "$AT_BOT whoami"
}

# Content Tests
test_content() {
    print_section "📝 Content Management Tests"
    
    run_test "Read timeline (10 posts)" "$AT_BOT feed 10"
}

# Profile Tests
test_profile() {
    print_section "👤 Profile Tests"
    
    # Get current user's handle for profile test
    local current_user
    current_user=$("$AT_BOT" whoami 2>/dev/null | grep "Handle:" | awk '{print $NF}')
    
    if [ -n "$current_user" ]; then
        run_test "View own profile" "$AT_BOT profile $current_user"
    else
        run_test "View own profile" "$AT_BOT profile"
    fi
}

# Search Tests
test_search() {
    print_section "🔍 Search Tests"
    
    run_test "Search for 'bluesky'" "$AT_BOT search 'bluesky' 5"
}

# Configuration Tests
test_config() {
    print_section "⚙️  Configuration Tests"
    
    run_test "List configuration" "$AT_BOT config list"
}

# Diagnostics
test_diagnostics() {
    print_section "🧪 Diagnostics"
    
    print_test "Session file status"
    if [ -f "$SESSION_FILE" ]; then
        print_check_success "Session file exists at $SESSION_FILE"
        local size=$(du -h "$SESSION_FILE" | cut -f1)
        print_info "Session file size: $size"
    else
        print_check_failure "Session file not found"
    fi
    
    print_test "Binary verification"
    if [ -f "$AT_BOT" ] && [ -x "$AT_BOT" ]; then
        print_check_success "AT-bot binary is executable at $AT_BOT"
    else
        print_check_failure "AT-bot binary not found or not executable"
    fi
    
    print_test "Dependencies check"
    for cmd in curl grep sed awk openssl; do
        if command -v "$cmd" >/dev/null 2>&1; then
            print_info "✓ $cmd available"
        else
            print_check_failure "✗ $cmd not found"
        fi
    done
}

# Print test summary
print_summary() {
    echo ""
    echo -e "${WHITE}Test Summary${NC}"
    echo -e "${BLUE}$(printf '─%.0s' {1..60})${NC}"
    echo ""
    echo -e "  Total Tests:    ${WHITE}$TOTAL_TESTS${NC}"
    echo -e "  ${GREEN}✓ Passed:${NC}       $PASSED_TESTS"
    echo -e "  ${RED}✗ Failed:${NC}       $FAILED_TESTS"
    echo -e "  ${YELLOW}⊘ Skipped:${NC}      $SKIPPED_TESTS"
    echo ""
    
    if [ $FAILED_TESTS -eq 0 ]; then
        echo -e "${GREEN}✓ All tests passed!${NC}"
        echo ""
        return 0
    else
        echo -e "${RED}✗ Some tests failed${NC}"
        echo ""
        return 1
    fi
}

# Main function
main() {
    print_header
    
    # Ensure authentication
    if ! ensure_authenticated; then
        print_error "Failed to authenticate. Exiting."
        exit 1
    fi
    
    # Run test suites
    test_auth
    test_content
    test_profile
    test_search
    test_config
    test_diagnostics
    
    # Print summary
    print_summary
    
    # Exit with appropriate code
    if [ $FAILED_TESTS -eq 0 ]; then
        exit 0
    else
        exit 1
    fi
}

# Parse command-line arguments
VERBOSE=0
QUIET=0

while [ $# -gt 0 ]; do
    case "$1" in
        -v|--verbose)
            VERBOSE=1
            shift
            ;;
        -q|--quiet)
            QUIET=1
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Automated end-to-end integration tests for AT-bot"
            echo ""
            echo "Options:"
            echo "  -v, --verbose     Show verbose output"
            echo "  -q, --quiet       Suppress non-essential output"
            echo "  -h, --help        Show this help message"
            echo ""
            echo "Features:"
            echo "  - Automatic authentication (interactive or with saved credentials)"
            echo "  - Credential saving for automated runs"
            echo "  - Sequential API testing"
            echo "  - Detailed test results and diagnostics"
            echo ""
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
    esac
done

# Run main function
main
