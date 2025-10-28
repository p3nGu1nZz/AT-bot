#!/bin/bash
# Test: Post and feed functionality

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
AT_BOT="$PROJECT_ROOT/bin/at-bot"

# Test that post command requires text
test_post_requires_text() {
    output=$("$AT_BOT" post 2>&1 || true)
    echo "$output" | grep -q "Post text is required"
}

# Test that post command requires login
test_post_requires_login() {
    # Make sure we're logged out
    rm -f ~/.config/at-bot/session.json 2>/dev/null || true
    
    output=$("$AT_BOT" post "test" 2>&1 || true)
    echo "$output" | grep -q "Not logged in"
}

# Test that feed command requires login
test_feed_requires_login() {
    # Make sure we're logged out
    rm -f ~/.config/at-bot/session.json 2>/dev/null || true
    
    output=$("$AT_BOT" feed 2>&1 || true)
    echo "$output" | grep -q "Not logged in"
}

# Test help includes new commands
test_help_includes_post() {
    "$AT_BOT" help | grep -q "post"
    "$AT_BOT" help | grep -q "feed"
}

# Run tests
test_post_requires_text || exit 1
test_post_requires_login || exit 1
test_feed_requires_login || exit 1
test_help_includes_post || exit 1

exit 0
