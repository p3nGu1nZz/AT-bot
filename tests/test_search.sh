#!/bin/bash
# Test search functionality

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "Testing Search Functionality"
echo "============================"
echo ""

# Test 1: Search command requires argument
echo "Test 1: Search command requires query argument"
if "$PROJECT_ROOT/bin/atproto" search 2>/dev/null; then
    echo "✗ Failed: Should require query argument"
    exit 1
fi
echo "✓ Search requires query argument"

# Test 2: Search requires authentication
echo "Test 2: Search requires authentication"
# Clear any existing session
rm -f ~/.config/atproto/session.json 2>/dev/null || true
if "$PROJECT_ROOT/bin/atproto" search "test query" 2>&1 | grep -q "Not logged in"; then
    echo "✓ Search requires authentication"
else
    echo "✗ Failed: Should require authentication"
    exit 1
fi

# Test 3: Help text includes search
echo "Test 3: Help includes search command"
help_output=$("$PROJECT_ROOT/bin/atproto" help)
if echo "$help_output" | grep -q "search.*Search for posts"; then
    echo "✓ Help includes search command"
else
    echo "✗ Failed: Help should include search command"
    exit 1
fi

# Test 4: Search command accepts query and optional limit
echo "Test 4: Search accepts query and optional limit"
# This just checks the command structure, not actual execution
if "$PROJECT_ROOT/bin/atproto" search 2>&1 | grep -q "Usage.*search.*query"; then
    echo "✓ Search has correct usage format"
else
    echo "✗ Failed: Search should show correct usage"
    exit 1
fi

echo ""
echo "All search tests passed! ✓"
exit 0
