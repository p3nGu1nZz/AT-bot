#!/bin/bash
# Test: AT Protocol library functions

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LIB_ATPROTO="$PROJECT_ROOT/lib/atproto.sh"

# Test that library exists
test_library_exists() {
    [ -f "$LIB_ATPROTO" ]
}

# Test that library can be sourced
test_library_source() {
    # shellcheck source=../lib/atproto.sh
    source "$LIB_ATPROTO"
}

# Test that required functions exist
test_functions_exist() {
    # shellcheck source=../lib/atproto.sh
    source "$LIB_ATPROTO"
    
    # Check that key functions are defined
    type atproto_login > /dev/null 2>&1
    type atproto_logout > /dev/null 2>&1
    type atproto_whoami > /dev/null 2>&1
    type api_request > /dev/null 2>&1
}

# Run tests
test_library_exists || exit 1
test_library_source || exit 1
test_functions_exist || exit 1

exit 0
