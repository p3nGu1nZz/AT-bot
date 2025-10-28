#!/bin/bash
# AT-bot Unit Test Runner
#
# This script runs all unit tests in the tests/ directory and provides
# comprehensive reporting, filtering, and CI/CD integration support.
#
# Usage:
#   test-unit.sh [options] [test_pattern]
#
# Options:
#   -v, --verbose          Show detailed test output and logs
#   -q, --quiet            Suppress output, only show results
#   -c, --coverage         Show test coverage information
#   -l, --list             List available tests without running
#   -f, --failed-only      Only show failed tests
#   -h, --help             Show this help message
#
# Examples:
#   test-unit.sh                    # Run all tests
#   test-unit.sh test_cli           # Run tests matching 'test_cli*'
#   test-unit.sh --verbose          # Run all tests with detailed output
#   test-unit.sh --list             # List available tests
#   test-unit.sh --failed-only      # Only show failed tests
#   make test-unit                  # Run via make command

set -o pipefail

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TESTS_DIR="$PROJECT_ROOT/tests"

# Source reporter library for console display functions
if [ -f "$PROJECT_ROOT/lib/reporter.sh" ]; then
    source "$PROJECT_ROOT/lib/reporter.sh"
else
    echo "Error: reporter.sh not found" >&2
    exit 1
fi

# Test statistics
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0
TESTS_TOTAL=0

# Options
VERBOSE=false
QUIET=false
SHOW_COVERAGE=false
LIST_ONLY=false
FAILED_ONLY=false
TEST_PATTERN=""

# Temporary file for test output
TEST_OUTPUT=$(mktemp)
FAILED_TESTS_FILE=$(mktemp)
trap "rm -f $TEST_OUTPUT $FAILED_TESTS_FILE" EXIT

# Note: Logging functions (log_info, log_success, log_error, log_warning, log_skip)
# are now provided by lib/reporter.sh which is sourced above

# Print help
show_help() {
    cat << 'EOF'
AT-bot Unit Test Runner

Usage:
  test-unit.sh [options] [test_pattern]

Options:
  -v, --verbose          Show detailed test output and logs
  -q, --quiet            Suppress output, only show results
  -c, --coverage         Show test coverage information
  -l, --list             List available tests without running
  -f, --failed-only      Only show failed tests in final report
  -h, --help             Show this help message

Test Pattern:
  Optional pattern to run specific tests (e.g., 'test_cli' or 'config')
  Wildcards and partial matches supported

Examples:
  test-unit.sh                    # Run all tests
  test-unit.sh test_cli           # Run tests matching 'test_cli*'
  test-unit.sh --verbose          # Run all tests with verbose output
  test-unit.sh --list             # List available tests
  test-unit.sh --coverage         # Show test coverage information
  test-unit.sh --failed-only      # Only show failed tests

Test Categories:
  Authentication Tests:
    test_cli_basic.sh        - Basic CLI functionality (help, version, commands)
    test_encryption.sh       - Encryption and credential storage
    test_profile.sh          - User profile retrieval and management

  Content Management Tests:
    test_post_feed.sh        - Post creation and feed operations
    test_media_upload.sh     - Media upload and attachment handling

  Social Operations Tests:
    test_follow.sh           - Follow and relationship management
    test_followers.sh        - Follower/following list operations
    test_search.sh           - Post and user search functionality

  Configuration Tests:
    test_config.sh           - Configuration management
    test_library.sh          - Library function testing

  Integration Tests:
    atp_test.sh              - Comprehensive AT Protocol integration
    manual_test.sh           - Manual testing utilities
    debug_demo.sh            - Debug mode demonstrations

CI/CD Integration:
  Exit codes: 0 = all pass, 1 = some failed, 2 = invalid arguments
  Output formats support piping and log aggregation
  JSON export available via --json flag (future)

Environment Variables:
  AT_BOT_TEST_VERBOSE  - Enable verbose output
  AT_BOT_TEST_TIMEOUT  - Test timeout in seconds (default: 60)
  AT_BOT_DEBUG         - Enable debug mode for tests

For more information, visit: https://github.com/p3nGu1nZz/AT-bot

EOF
}

# Parse command-line arguments
parse_arguments() {
    while [ $# -gt 0 ]; do
        case "$1" in
            -v|--verbose)
                VERBOSE=true
                ;;
            -q|--quiet)
                QUIET=true
                ;;
            -c|--coverage)
                SHOW_COVERAGE=true
                ;;
            -l|--list)
                LIST_ONLY=true
                ;;
            -f|--failed-only)
                FAILED_ONLY=true
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            -*)
                log_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 2
                ;;
            *)
                TEST_PATTERN="$1"
                ;;
        esac
        shift
    done
}

# List all available tests
list_tests() {
    log_info "Available unit tests in $TESTS_DIR:"
    echo ""
    
    declare -A categories
    categories[Authentication]="test_cli_basic.sh test_encryption.sh test_profile.sh"
    categories[Content]="test_post_feed.sh test_media_upload.sh"
    categories[Social]="test_follow.sh test_followers.sh test_search.sh"
    categories[Configuration]="test_config.sh test_library.sh"
    categories[Integration]="atp_test.sh manual_test.sh debug_demo.sh"
    
    for cat_name in "${!categories[@]}"; do
        echo -e "${CYAN}${cat_name} Tests:${NC}"
        
        for test in ${categories[$cat_name]}; do
            if [ -f "$TESTS_DIR/$test" ]; then
                local lines=$(wc -l < "$TESTS_DIR/$test" 2>/dev/null || echo "0")
                printf "  %-30s (%3d lines)\n" "$test" "$lines"
            fi
        done
        echo ""
    done
    
    log_info "Total test files: $(find "$TESTS_DIR" -name 'test_*.sh' -o -name '*_test.sh' | wc -l)"
}

# Get test description from file
get_test_description() {
    local test_file="$1"
    # Extract first comment line that looks like a description
    grep -m1 '^# Test:' "$test_file" 2>/dev/null | sed 's/^# Test: //' || echo "No description"
}

# Run a single test
run_test() {
    local test_file="$1"
    local test_name
    test_name=$(basename "$test_file" .sh)
    
    # Skip if doesn't match pattern
    if [ -n "$TEST_PATTERN" ] && ! [[ "$test_name" =~ $TEST_PATTERN ]]; then
        return 2  # Skip code
    fi
    
    log_info "Running: $test_name"
    
    if [ "$VERBOSE" = true ]; then
        # Show test description
        local desc
        desc=$(get_test_description "$test_file")
        echo "  Description: $desc"
    fi
    
    # Run test with timeout and capture output
    local test_timeout="${AT_BOT_TEST_TIMEOUT:-60}"
    local test_output
    local test_exit_code
    
    test_output=$( (timeout "$test_timeout" bash "$test_file" 2>&1) 2>&1; echo "EXIT:$?" )
    test_exit_code=${test_output##*EXIT:}
    test_output=${test_output%EXIT:*}
    
    # Check timeout
    if [ "$test_exit_code" = "124" ]; then
        log_error "$test_name (TIMEOUT after ${test_timeout}s)"
        echo "$test_name" >> "$FAILED_TESTS_FILE"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        [ "$VERBOSE" = true ] && echo "  Error: Test exceeded timeout limit"
        return 1
    fi
    
    # Process result
    if [ "$test_exit_code" = "0" ]; then
        log_success "$test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        [ "$VERBOSE" = true ] && [ -n "$test_output" ] && echo "  Output: $test_output" | head -n 5
        return 0
    else
        log_error "$test_name (exit code: $test_exit_code)"
        echo "$test_name" >> "$FAILED_TESTS_FILE"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        if [ "$VERBOSE" = true ]; then
            echo "  Error output:"
            echo "$test_output" | sed 's/^/    /' | head -n 10
        fi
        return 1
    fi
}

# Print test summary
print_summary() {
    TESTS_TOTAL=$((TESTS_PASSED + TESTS_FAILED))
    
    # Use reporter.sh test_summary function
    test_summary "$TESTS_PASSED" "$TESTS_FAILED" "$TESTS_SKIPPED"
    
    # Show failed tests if any
    if [ -s "$FAILED_TESTS_FILE" ]; then
        echo -e "${RED}Failed Tests:${NC}"
        sed 's/^/  /' "$FAILED_TESTS_FILE"
        echo ""
    fi
    
    echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
}

# Print coverage information
print_coverage() {
    echo ""
    echo -e "${BLUE}Test Coverage Information${NC}"
    echo -e "${BLUE}════════════════════════════════════${NC}"
    
    # Count functions in library
    local lib_functions
    lib_functions=$(grep -c '^[a-z_]*() {' "$PROJECT_ROOT/lib/atproto.sh" 2>/dev/null || echo "0")
    
    # Count CLI commands
    local cli_commands
    cli_commands=$(grep -c 'case.*in' "$PROJECT_ROOT/bin/at-bot" 2>/dev/null || echo "0")
    
    echo "  Library functions: $lib_functions"
    echo "  CLI commands defined: $cli_commands"
    echo "  Test files: $(find "$TESTS_DIR" -name 'test_*.sh' | wc -l)"
    echo "  Total test lines: $(find "$TESTS_DIR" -name 'test_*.sh' -exec wc -l {} + 2>/dev/null | tail -1 | awk '{print $1}')"
    
    echo ""
    echo -e "  For detailed coverage analysis, use:"
    echo -e "    ${CYAN}make test-coverage${NC}"
    echo ""
}

# Main execution
main() {
    parse_arguments "$@"
    
    # Show header
    if [ "$LIST_ONLY" = true ]; then
        list_tests
        return 0
    fi
    
    # Header
    if [ "$QUIET" = false ]; then
        section "AT-bot Unit Test Runner"
        
        if [ -n "$TEST_PATTERN" ]; then
            log_info "Running tests matching pattern: $TEST_PATTERN"
        fi
        echo ""
    fi
    
    # Verify tests directory exists
    if [ ! -d "$TESTS_DIR" ]; then
        log_error "Tests directory not found: $TESTS_DIR"
        exit 2
    fi
    
    # Run all test files
    local test_count=0
    for test_file in "$TESTS_DIR"/test_*.sh "$TESTS_DIR"/*_test.sh; do
        if [ -f "$test_file" ]; then
            run_test "$test_file"
            local result=$?
            
            if [ "$result" -ne 2 ]; then  # 2 is skip
                test_count=$((test_count + 1))
            else
                TESTS_SKIPPED=$((TESTS_SKIPPED + 1))
            fi
        fi
    done
    
    # Print summary
    print_summary
    
    # Show coverage if requested
    [ "$SHOW_COVERAGE" = true ] && print_coverage
    
    # Determine exit code
    if [ "$TESTS_FAILED" -eq 0 ]; then
        [ "$QUIET" = false ] && log_success "All tests passed!"
        return 0
    else
        [ "$QUIET" = false ] && log_error "Some tests failed. Run with --verbose for details."
        return 1
    fi
}

# Run main if executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi
