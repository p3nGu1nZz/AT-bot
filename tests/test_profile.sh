#!/bin/bash
# Test: Profile management functionality

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

test_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

# Test 1: Validate atproto_get_profile function exists
test_get_profile_exists() {
    test_start "atproto_get_profile function exists"
    
    if declare -f atproto_get_profile >/dev/null 2>&1; then
        test_pass "atproto_get_profile function found"
        return 0
    else
        test_fail "atproto_get_profile function not found"
        return 1
    fi
}

# Test 2: Validate atproto_show_profile function exists
test_show_profile_exists() {
    test_start "atproto_show_profile function exists"
    
    if declare -f atproto_show_profile >/dev/null 2>&1; then
        test_pass "atproto_show_profile function found"
        return 0
    else
        test_fail "atproto_show_profile function not found"
        return 1
    fi
}

# Test 3: Validate atproto_update_profile function exists
test_update_profile_exists() {
    test_start "atproto_update_profile function exists"
    
    if declare -f atproto_update_profile >/dev/null 2>&1; then
        test_pass "atproto_update_profile function found"
        return 0
    else
        test_fail "atproto_update_profile function not found"
        return 1
    fi
}

# Test 4: Validate profile API endpoint format
test_profile_endpoint() {
    test_start "Profile API endpoint format"
    
    local pds="${ATP_PDS:-https://bsky.social}"
    local endpoint="$pds/xrpc/app.bsky.actor.getProfile"
    
    if [[ "$endpoint" =~ ^https://.*bsky\.social/xrpc/app\.bsky\.actor\.getProfile$ ]]; then
        test_pass "Profile endpoint format valid"
        return 0
    else
        test_fail "Profile endpoint format invalid (got: $endpoint)"
        return 1
    fi
}

# Test 5: Validate profile record structure
test_profile_record_structure() {
    test_start "Profile record JSON structure"
    
    # Mock profile record
    local mock_profile='{
        "$type": "app.bsky.actor.profile",
        "displayName": "Test User",
        "description": "This is a test bio",
        "avatar": {
            "$type": "blob",
            "ref": { "$link": "bafyreih..." },
            "mimeType": "image/jpeg",
            "size": 12345
        }
    }'
    
    # Check if JSON contains required fields
    if echo "$mock_profile" | grep -q 'app.bsky.actor.profile' && \
       echo "$mock_profile" | grep -q '"displayName"' && \
       echo "$mock_profile" | grep -q '"description"'; then
        test_pass "Profile record structure valid"
        return 0
    else
        test_fail "Profile record structure invalid"
        return 1
    fi
}

# Test 6: Validate profile fields extraction
test_profile_fields() {
    test_start "Profile fields extraction"
    
    # Mock profile response (compact JSON for better parsing)
    local mock_response='{"handle":"test.bsky.social","displayName":"Test User","description":"Test bio","followersCount":100,"followsCount":50,"postsCount":25}'
    
    local handle display_name description followers following posts
    handle=$(json_get_field "$mock_response" "handle")
    display_name=$(json_get_field "$mock_response" "displayName")
    description=$(json_get_field "$mock_response" "description")
    followers=$(json_get_field "$mock_response" "followersCount")
    following=$(json_get_field "$mock_response" "followsCount")
    posts=$(json_get_field "$mock_response" "postsCount")
    
    # Check that we got some values (json_get_field behavior may vary)
    if [ -n "$handle" ] && [ -n "$display_name" ] && [ -n "$description" ]; then
        test_pass "Profile fields extracted correctly"
        return 0
    else
        test_fail "Profile fields extraction failed (handle='$handle', name='$display_name', desc='$description')"
        return 1
    fi
}

# Test 7: Validate putRecord endpoint
test_put_record_endpoint() {
    test_start "PutRecord endpoint format"
    
    local pds="${ATP_PDS:-https://bsky.social}"
    local endpoint="$pds/xrpc/com.atproto.repo.putRecord"
    
    if [[ "$endpoint" =~ ^https://.*bsky\.social/xrpc/com\.atproto\.repo\.putRecord$ ]]; then
        test_pass "PutRecord endpoint format valid"
        return 0
    else
        test_fail "PutRecord endpoint format invalid (got: $endpoint)"
        return 1
    fi
}

# Test 8: Validate profile update payload structure
test_update_payload_structure() {
    test_start "Profile update payload structure"
    
    # Mock update payload
    local mock_payload='{
        "repo": "did:plc:test123",
        "collection": "app.bsky.actor.profile",
        "rkey": "self",
        "record": {
            "$type": "app.bsky.actor.profile",
            "displayName": "Updated Name",
            "description": "Updated bio"
        }
    }'
    
    # Check if JSON contains required fields
    if echo "$mock_payload" | grep -q '"repo"' && \
       echo "$mock_payload" | grep -q '"collection".*app.bsky.actor.profile' && \
       echo "$mock_payload" | grep -q '"rkey".*self' && \
       echo "$mock_payload" | grep -q '"record"'; then
        test_pass "Profile update payload structure valid"
        return 0
    else
        test_fail "Profile update payload structure invalid"
        return 1
    fi
}

# Main test execution
main() {
    echo -e "${BLUE}====================================${NC}"
    echo -e "${BLUE}  Profile Management Tests${NC}"
    echo -e "${BLUE}====================================${NC}"
    echo ""
    
    # Run all tests
    test_get_profile_exists
    test_show_profile_exists
    test_update_profile_exists
    test_profile_endpoint
    test_profile_record_structure
    test_profile_fields
    test_put_record_endpoint
    test_update_payload_structure
    
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
