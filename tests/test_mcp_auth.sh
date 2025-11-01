#!/bin/bash
# Test MCP Server Authentication Flow
# This script tests the complete authentication cycle through MCP

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
MCP_SERVER="$PROJECT_ROOT/mcp-server/atproto-mcp"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Helper functions
print_header() {
    echo -e "\n${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}\n"
}

print_test() {
    echo -e "${YELLOW}TEST:${NC} $1"
}

print_pass() {
    echo -e "${GREEN}✓ PASS:${NC} $1"
    ((TESTS_PASSED++))
}

print_fail() {
    echo -e "${RED}✗ FAIL:${NC} $1"
    ((TESTS_FAILED++))
}

print_info() {
    echo -e "${BLUE}INFO:${NC} $1"
}

# Call MCP tool
call_mcp_tool() {
    local tool_name="$1"
    local arguments="$2"
    local request
    
    if [ -n "$arguments" ]; then
        request="{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"tools/call\",\"params\":{\"name\":\"$tool_name\",\"arguments\":$arguments}}"
    else
        request="{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"tools/call\",\"params\":{\"name\":\"$tool_name\",\"arguments\":{}}}"
    fi
    
    echo "$request" | timeout 10 "$MCP_SERVER" 2>&1
}

# Test 1: MCP Server Startup
test_server_startup() {
    print_header "Test 1: MCP Server Startup"
    ((TESTS_RUN++))
    
    print_test "Starting MCP server and checking output"
    
    local output
    output=$(timeout 2 "$MCP_SERVER" 2>&1 || true)
    
    if echo "$output" | grep -q "atproto MCP Server started successfully"; then
        print_pass "Server started successfully"
    else
        print_fail "Server failed to start"
        return 1
    fi
    
    if echo "$output" | grep -q "Registered 29 tools"; then
        print_pass "29 tools registered"
    else
        print_fail "Tools not registered correctly"
        return 1
    fi
    
    print_info "Server startup test completed"
}

# Test 2: Tool Discovery
test_tool_discovery() {
    print_header "Test 2: Tool Discovery (tools/list)"
    ((TESTS_RUN++))
    
    print_test "Requesting tool list from MCP server"
    
    local response
    response=$(echo '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' | timeout 5 "$MCP_SERVER" 2>&1)
    
    if echo "$response" | grep -q '"result"'; then
        print_pass "Received valid response"
    else
        print_fail "Invalid response format"
        echo "$response"
        return 1
    fi
    
    # Check for authentication tools
    if echo "$response" | grep -q '"name":"auth_login"'; then
        print_pass "auth_login tool found"
    else
        print_fail "auth_login tool not found"
    fi
    
    if echo "$response" | grep -q '"name":"auth_logout"'; then
        print_pass "auth_logout tool found"
    else
        print_fail "auth_logout tool not found"
    fi
    
    if echo "$response" | grep -q '"name":"auth_whoami"'; then
        print_pass "auth_whoami tool found"
    else
        print_fail "auth_whoami tool not found"
    fi
    
    if echo "$response" | grep -q '"name":"auth_is_authenticated"'; then
        print_pass "auth_is_authenticated tool found"
    else
        print_fail "auth_is_authenticated tool not found"
    fi
    
    # Count tools
    local tool_count
    tool_count=$(echo "$response" | grep -o '"name":"[^"]*"' | wc -l)
    print_info "Total tools discovered: $tool_count"
    
    if [ "$tool_count" -eq 29 ]; then
        print_pass "All 29 tools accounted for"
    else
        print_fail "Expected 29 tools, found $tool_count"
    fi
}

# Test 3: Authentication Status Check (before login)
test_auth_status_before() {
    print_header "Test 3: Check Authentication Status (Before Login)"
    ((TESTS_RUN++))
    
    print_test "Calling auth_is_authenticated tool"
    
    local response
    response=$(call_mcp_tool "auth_is_authenticated" "")
    
    print_info "Response: $response"
    
    if echo "$response" | grep -q '"result"'; then
        print_pass "Received valid MCP response"
    else
        print_fail "Invalid MCP response format"
        return 1
    fi
    
    # Check if authenticated (should be false if no session)
    if echo "$response" | grep -q '"content"'; then
        print_pass "Tool executed successfully"
    else
        print_fail "Tool execution failed"
        return 1
    fi
}

# Test 4: Tool Execution for Each Category
test_tool_execution() {
    print_header "Test 4: Tool Execution for Each Category"
    
    print_test "Testing authentication tools (without actual login)"
    ((TESTS_RUN++))
    
    # Test auth_is_authenticated
    print_info "Testing: auth_is_authenticated"
    local response
    response=$(call_mcp_tool "auth_is_authenticated" "")
    if echo "$response" | grep -q '"result"'; then
        print_pass "auth_is_authenticated executed"
    else
        print_fail "auth_is_authenticated failed"
    fi
    
    # Test auth_whoami (will fail if not logged in, but should return proper error)
    print_info "Testing: auth_whoami (expected to show not logged in)"
    response=$(call_mcp_tool "auth_whoami" "")
    if echo "$response" | grep -q '"result"'; then
        print_pass "auth_whoami executed (returns not logged in status)"
    else
        print_fail "auth_whoami failed to execute"
    fi
    
    print_info "Authentication tool execution tests completed"
    print_info "Note: Full login test requires actual credentials"
}

# Main test execution
main() {
    print_header "MCP Server Authentication Flow Test Suite"
    
    echo -e "${BLUE}Project Root:${NC} $PROJECT_ROOT"
    echo -e "${BLUE}MCP Server:${NC} $MCP_SERVER"
    echo -e "${BLUE}Date:${NC} $(date)"
    echo ""
    
    # Check if MCP server exists
    if [ ! -f "$MCP_SERVER" ]; then
        echo -e "${RED}ERROR:${NC} MCP server not found at $MCP_SERVER"
        echo "Please build the MCP server first: cd mcp-server && npm install && npm run build"
        exit 1
    fi
    
    if [ ! -x "$MCP_SERVER" ]; then
        echo -e "${RED}ERROR:${NC} MCP server is not executable"
        echo "Run: chmod +x $MCP_SERVER"
        exit 1
    fi
    
    # Run tests
    test_server_startup || true
    test_tool_discovery || true
    test_auth_status_before || true
    test_tool_execution || true
    
    # Print summary
    print_header "Test Summary"
    echo -e "${BLUE}Tests Run:${NC}    $TESTS_RUN"
    echo -e "${GREEN}Tests Passed:${NC} $TESTS_PASSED"
    echo -e "${RED}Tests Failed:${NC} $TESTS_FAILED"
    echo ""
    
    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}✓ All tests passed!${NC}"
        exit 0
    else
        echo -e "${RED}✗ Some tests failed${NC}"
        exit 1
    fi
}

# Run main
main "$@"
