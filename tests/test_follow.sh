#!/bin/bash
# Test follow/unfollow functionality

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "Testing Follow/Unfollow Functionality"
echo "======================================"
echo ""

# Test 1: Follow command requires argument
echo "Test 1: Follow command requires handle argument"
if "$PROJECT_ROOT/bin/at-bot" follow 2>/dev/null; then
    echo "✗ Failed: Should require handle argument"
    exit 1
fi
echo "✓ Follow requires handle argument"

# Test 2: Unfollow command requires argument
echo "Test 2: Unfollow command requires handle argument"
if "$PROJECT_ROOT/bin/at-bot" unfollow 2>/dev/null; then
    echo "✗ Failed: Should require handle argument"
    exit 1
fi
echo "✓ Unfollow requires handle argument"

# Test 3: Follow requires authentication
echo "Test 3: Follow requires authentication"
# Clear any existing session
rm -f ~/.config/at-bot/session.json 2>/dev/null || true
if "$PROJECT_ROOT/bin/at-bot" follow test.bsky.social 2>&1 | grep -q "Not logged in"; then
    echo "✓ Follow requires authentication"
else
    echo "✗ Failed: Should require authentication"
    exit 1
fi

# Test 4: Unfollow requires authentication
echo "Test 4: Unfollow requires authentication"
if "$PROJECT_ROOT/bin/at-bot" unfollow test.bsky.social 2>&1 | grep -q "Not logged in"; then
    echo "✓ Unfollow requires authentication"
else
    echo "✗ Failed: Should require authentication"
    exit 1
fi

# Test 5: Help text includes follow/unfollow
echo "Test 5: Help includes follow/unfollow commands"
help_output=$("$PROJECT_ROOT/bin/at-bot" help)
if echo "$help_output" | grep -q "follow.*Follow a user"; then
    echo "✓ Help includes follow command"
else
    echo "✗ Failed: Help should include follow command"
    exit 1
fi
if echo "$help_output" | grep -q "unfollow.*Unfollow a user"; then
    echo "✓ Help includes unfollow command"
else
    echo "✗ Failed: Help should include unfollow command"
    exit 1
fi

echo ""
echo "All follow/unfollow tests passed! ✓"
exit 0
