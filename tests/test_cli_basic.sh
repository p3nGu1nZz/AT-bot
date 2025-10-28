#!/bin/bash
# Test: CLI basic functionality

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
AT_BOT="$PROJECT_ROOT/bin/at-bot"

# Test that at-bot exists and is executable
test_executable() {
    [ -x "$AT_BOT" ]
}

# Test help command
test_help() {
    "$AT_BOT" help | grep -q "AT-bot"
    "$AT_BOT" --help | grep -q "Usage"
    "$AT_BOT" -h | grep -q "Commands"
}

# Test version command
test_version() {
    "$AT_BOT" --version | grep -q "version"
    "$AT_BOT" -v | grep -q "AT-bot"
}

# Test invalid command
test_invalid_command() {
    output=$("$AT_BOT" invalid_command 2>&1 || true)
    echo "$output" | grep -q "Unknown command"
}

# Run tests
test_executable || exit 1
test_help || exit 1
test_version || exit 1
test_invalid_command || exit 1

exit 0
