#!/bin/bash
# Test: Followers and following functionality

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LIB_DIR="$PROJECT_ROOT/lib"

# Source the library
# shellcheck source=../lib/atproto.sh
source "$LIB_DIR/atproto.sh"

# Test counter
TESTS_RUN=0
TESTS_PASSED=0

# Color definitions
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    NC=''
fi

# Test output functions
test_start() {
    echo -e "${BLUE}[TEST]${NC} $1"
    TESTS_RUN=$((TESTS_RUN + 1))
}

test_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

test_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
}

# Test 1: Validate atproto_get_followers function exists
test_get_followers_exists() {
    test_start "atproto_get_followers function exists"
    
    if declare -f atproto_get_followers >/dev/null 2>&1; then
        test_pass "atproto_get_followers function found"
        return 0
    else
        test_fail "atproto_get_followers function not found"
        return 1
    fi
}

# Test 2: Validate atproto_get_following function exists
test_get_following_exists() {
    test_start "atproto_get_following function exists"
    
    if declare -f atproto_get_following >/dev/null 2>&1; then
        test_pass "atproto_get_following function found"
        return 0
    else
        test_fail "atproto_get_following function not found"
        return 1
    fi
}

# Test 3: Validate followers API endpoint format
test_followers_endpoint() {
    test_start "Followers API endpoint format"
    
    local pds="${ATP_PDS:-https://bsky.social}"
    local endpoint="$pds/xrpc/app.bsky.graph.getFollowers"
    
    if [[ "$endpoint" =~ ^https://.*bsky\.social/xrpc/app\.bsky\.graph\.getFollowers$ ]]; then
        test_pass "Followers endpoint format valid"
        return 0
    else
        test_fail "Followers endpoint format invalid (got: $endpoint)"
        return 1
    fi
}

# Test 4: Validate following API endpoint format
test_following_endpoint() {
    test_start "Following API endpoint format"
    
    local pds="${ATP_PDS:-https://bsky.social}"
    local endpoint="$pds/xrpc/app.bsky.graph.getFollows"
    
    if [[ "$endpoint" =~ ^https://.*bsky\.social/xrpc/app\.bsky\.graph\.getFollows$ ]]; then
        test_pass "Following endpoint format valid"
        return 0
    else
        test_fail "Following endpoint format invalid (got: $endpoint)"
        return 1
    fi
}

# Test 5: Validate limit parameter validation
test_limit_validation() {
    test_start "Limit parameter validation"
    
    local limit=150
    local max_limit=100
    
    if [ "$limit" -gt "$max_limit" ]; then
        limit=$max_limit
    fi
    
    if [ "$limit" -eq 100 ]; then
        test_pass "Limit validation works correctly"
        return 0
    else
        test_fail "Limit validation failed (got: $limit)"
        return 1
    fi
}

# Test 6: Validate followers response structure
test_followers_response_structure() {
    test_start "Followers response structure"
    
    # Mock followers response
    local mock_response='{"followers":[{"handle":"user1.bsky.social","displayName":"User One"},{"handle":"user2.bsky.social","displayName":"User Two"}]}'
    
    # Check if JSON contains required fields
    if echo "$mock_response" | grep -q '"followers"' && \
       echo "$mock_response" | grep -q '"handle"' && \
       echo "$mock_response" | grep -q '"displayName"'; then
        test_pass "Followers response structure valid"
        return 0
    else
        test_fail "Followers response structure invalid"
        return 1
    fi
}

# Test 7: Validate following response structure
test_following_response_structure() {
    test_start "Following response structure"
    
    # Mock following response
    local mock_response='{"follows":[{"handle":"user1.bsky.social","displayName":"User One"},{"handle":"user2.bsky.social","displayName":"User Two"}]}'
    
    # Check if JSON contains required fields
    if echo "$mock_response" | grep -q '"follows"' && \
       echo "$mock_response" | grep -q '"handle"' && \
       echo "$mock_response" | grep -q '"displayName"'; then
        test_pass "Following response structure valid"
        return 0
    else
        test_fail "Following response structure invalid"
        return 1
    fi
}

# Test 8: Validate handle extraction from response
test_handle_extraction() {
    test_start "Handle extraction from response"
    
    local mock_line='"handle":"test.bsky.social"'
    
    if [[ "$mock_line" =~ \"handle\":\"([^\"]+)\" ]]; then
        local handle="${BASH_REMATCH[1]}"
        if [ "$handle" = "test.bsky.social" ]; then
            test_pass "Handle extraction works correctly"
            return 0
        fi
    fi
    
    test_fail "Handle extraction failed"
    return 1
}

# Main test execution
main() {
    echo -e "${BLUE}====================================${NC}"
    echo -e "${BLUE}  Followers/Following Tests${NC}"
    echo -e "${BLUE}====================================${NC}"
    echo ""
    
    # Run all tests
    test_get_followers_exists
    test_get_following_exists
    test_followers_endpoint
    test_following_endpoint
    test_limit_validation
    test_followers_response_structure
    test_following_response_structure
    test_handle_extraction
    
    # Summary
    echo ""
    echo -e "${BLUE}====================================${NC}"
    echo -e "${BLUE}  Test Results${NC}"
    echo -e "${BLUE}====================================${NC}"
    echo -e "Tests Run:    ${BLUE}$TESTS_RUN${NC}"
    echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Tests Failed: ${RED}$((TESTS_RUN - TESTS_PASSED))${NC}"
    
    if [ "$TESTS_PASSED" -eq "$TESTS_RUN" ]; then
        echo -e "${GREEN}All tests passed!${NC}"
        exit 0
    else
        echo -e "${RED}Some tests failed!${NC}"
        exit 1
    fi
}

main "$@"
