#!/bin/bash
# Test runner for AT-bot
# Runs all tests in the tests directory

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Test configuration
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Print test header
print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}AT-bot Test Suite${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
}

# Print test result
print_result() {
    local status=$1
    local test_name=$2
    
    if [ "$status" -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗${NC} $test_name"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
}

# Print summary
print_summary() {
    echo ""
    echo -e "${BLUE}================================${NC}"
    echo -e "Tests passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Tests failed: ${RED}$TESTS_FAILED${NC}"
    echo -e "Total tests:  $TESTS_TOTAL"
    echo -e "${BLUE}================================${NC}"
    
    if [ "$TESTS_FAILED" -eq 0 ]; then
        echo -e "${GREEN}All tests passed!${NC}"
        return 0
    else
        echo -e "${RED}Some tests failed!${NC}"
        return 1
    fi
}

# Run test
run_test() {
    local test_file=$1
    local test_name=$(basename "$test_file" .sh)
    
    if bash "$test_file" > /dev/null 2>&1; then
        print_result 0 "$test_name"
    else
        print_result 1 "$test_name"
    fi
}

# Main test execution
main() {
    print_header
    
    # Run all test files
    for test_file in "$SCRIPT_DIR"/test_*.sh; do
        if [ -f "$test_file" ]; then
            run_test "$test_file"
        fi
    done
    
    print_summary
}

main "$@"
