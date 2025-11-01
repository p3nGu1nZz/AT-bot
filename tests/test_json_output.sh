#!/bin/bash
# Test JSON output functionality
# This script tests the --json flag for various commands

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ATPROTO="$PROJECT_ROOT/bin/atproto"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS=0
PASSED=0
FAILED=0

echo ""
echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   JSON Output Feature Test Suite    ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
echo ""

# Helper function to check JSON validity
is_valid_json() {
    local json="$1"
    echo "$json" | grep -q '^{' && echo "$json" | grep -q '}$'
}

# Helper function to run a test
run_test() {
    local test_name="$1"
    local command="$2"
    local should_have_field="$3"
    
    TESTS=$((TESTS + 1))
    echo -n "Test $TESTS: $test_name... "
    
    # Run command
    local output
    output=$($command 2>&1)
    
    # Check if JSON
    if is_valid_json "$output"; then
        # Check for required field if specified
        if [ -n "$should_have_field" ]; then
            if echo "$output" | grep -q "\"$should_have_field\""; then
                echo -e "${GREEN}✓ PASS${NC}"
                PASSED=$((PASSED + 1))
                return 0
            else
                echo -e "${RED}✗ FAIL${NC} (missing field: $should_have_field)"
                FAILED=$((FAILED + 1))
                return 1
            fi
        else
            echo -e "${GREEN}✓ PASS${NC}"
            PASSED=$((PASSED + 1))
            return 0
        fi
    else
        echo -e "${RED}✗ FAIL${NC} (invalid JSON)"
        echo "Output: $output"
        FAILED=$((FAILED + 1))
        return 1
    fi
}

# Test 1: whoami with --json
run_test "whoami JSON output" "$ATPROTO --json whoami" "handle"

# Test 2: post with --json
run_test "post JSON output" "$ATPROTO --json post 'Test JSON: $(date +%s)'" "success"

# Test 3: profile with --json
run_test "profile JSON output" "$ATPROTO --json profile" "did"

# Test 4: feed with --json (first 5 items)
run_test "feed JSON output" "$ATPROTO --json feed 5" "feed"

# Test 5: search with --json
run_test "search JSON output" "$ATPROTO --json search '#testing' 5" "posts"

# Test 6: followers with --json
run_test "followers JSON output" "$ATPROTO --json followers 10" "followers"

# Test 7: following with --json
run_test "following JSON output" "$ATPROTO --json following 10" "follows"

# Summary
echo ""
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}Test Summary${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "Total Tests:  ${BLUE}$TESTS${NC}"
echo -e "Passed:       ${GREEN}$PASSED${NC}"
echo -e "Failed:       ${RED}$FAILED${NC}"

if [ $FAILED -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓ All tests passed!${NC}"
    echo ""
    exit 0
else
    echo ""
    echo -e "${RED}✗ Some tests failed${NC}"
    echo ""
    exit 1
fi
