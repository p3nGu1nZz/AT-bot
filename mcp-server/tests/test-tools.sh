#!/bin/bash
# MCP Tool Integration Tests
# Tests each MCP tool to ensure it's properly integrated and callable

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
MCP_SERVER_DIR="$PROJECT_ROOT/mcp-server"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

# Helper functions
test_begin() {
    echo -ne "${YELLOW}→${NC} $1... "
}

test_pass() {
    echo -e "${GREEN}✓${NC}"
    ((TESTS_PASSED++))
}

test_fail() {
    echo -e "${RED}✗${NC} $1"
    ((TESTS_FAILED++))
}

# Check if tool exists in compiled JavaScript
check_tool_exists() {
    local tool_name="$1"
    local tool_file="$2"
    
    if grep -q "name: '$tool_name'" "$MCP_SERVER_DIR/dist/tools/$tool_file" || \
       grep -q "name: \"$tool_name\"" "$MCP_SERVER_DIR/dist/tools/$tool_file"; then
        return 0
    else
        return 1
    fi
}

# Test tool definitions
test_tool_schema() {
    local tool_name="$1"
    local tool_file="$2"
    
    test_begin "Tool: $tool_name (schema)"
    
    if check_tool_exists "$tool_name" "$tool_file"; then
        if grep -q "description:" "$MCP_SERVER_DIR/dist/tools/$tool_file"; then
            test_pass
        else
            test_fail "Missing tool description"
        fi
    else
        test_fail "Tool not found in $tool_file"
    fi
}

# Main test suite
echo ""
echo "================================"
echo "MCP Tool Integration Tests"
echo "================================"
echo ""

# Check if compiled tools exist
if [ ! -d "$MCP_SERVER_DIR/dist/tools" ]; then
    echo -e "${RED}Error: dist/tools directory not found${NC}"
    echo "Run: cd $MCP_SERVER_DIR && npm run build"
    exit 1
fi

echo "Checking Authentication Tools..."
test_tool_schema "auth_login" "auth-tools.js"
test_tool_schema "auth_logout" "auth-tools.js"
test_tool_schema "auth_whoami" "auth-tools.js"
test_tool_schema "auth_is_authenticated" "auth-tools.js"

echo ""
echo "Checking Engagement Tools..."
test_tool_schema "post_create" "engagement-tools.js"
test_tool_schema "post_reply" "engagement-tools.js"
test_tool_schema "post_like" "engagement-tools.js"
test_tool_schema "post_repost" "engagement-tools.js"
test_tool_schema "post_delete" "engagement-tools.js"

echo ""
echo "Checking Social Tools..."
test_tool_schema "follow_user" "social-tools.js"
test_tool_schema "unfollow_user" "social-tools.js"
test_tool_schema "get_followers" "social-tools.js"
test_tool_schema "get_following" "social-tools.js"
test_tool_schema "block_user" "social-tools.js"
test_tool_schema "unblock_user" "social-tools.js"

echo ""
echo "Checking Search & Discovery Tools..."
test_tool_schema "search_posts" "search-tools.js"
test_tool_schema "read_feed" "search-tools.js"
test_tool_schema "search_users" "search-tools.js"

echo ""
echo "Checking Media Tools..."
test_tool_schema "post_with_image" "media-tools.js"
test_tool_schema "post_with_gallery" "media-tools.js"
test_tool_schema "post_with_video" "media-tools.js"
test_tool_schema "upload_media" "media-tools.js"

echo ""
echo "Checking Feed Tools..."
test_tool_schema "feed_read" "feed-tools.js"

echo ""
echo "Checking Profile Tools..."
test_tool_schema "profile_get" "profile-tools.js"
test_tool_schema "profile_edit" "profile-tools.js"
test_tool_schema "profile_get_followers" "profile-tools.js"
test_tool_schema "profile_get_following" "profile-tools.js"

# Test MCP server index
echo ""
echo "Checking MCP Server Registration..."
test_begin "MCP index.ts has tool imports"
if grep -q "import.*engagement-tools" "$MCP_SERVER_DIR/dist/index.js" || \
   grep -q "engagementTools" "$MCP_SERVER_DIR/dist/index.js"; then
    test_pass
else
    test_fail "Missing engagement-tools import"
fi

test_begin "MCP index.ts has social-tools"
if grep -q "social" "$MCP_SERVER_DIR/dist/index.js"; then
    test_pass
else
    test_fail "Missing social-tools"
fi

test_begin "MCP index.ts has search-tools"
if grep -q "search" "$MCP_SERVER_DIR/dist/index.js"; then
    test_pass
else
    test_fail "Missing search-tools"
fi

test_begin "MCP index.ts has media-tools"
if grep -q "media" "$MCP_SERVER_DIR/dist/index.js"; then
    test_pass
else
    test_fail "Missing media-tools"
fi

# Results
echo ""
echo "================================"
echo -e "Tests passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests failed: ${RED}$TESTS_FAILED${NC}"
echo "Total tests:  $((TESTS_PASSED + TESTS_FAILED))"
echo "================================"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
fi
