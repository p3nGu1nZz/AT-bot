#!/bin/bash
# Test configuration management

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LIB_DIR="$PROJECT_ROOT/lib"

# Source the config library
source "$LIB_DIR/config.sh"

# Test config directory
TEST_CONFIG_DIR="/tmp/at-bot-config-test-$$"
CONFIG_FILE="$TEST_CONFIG_DIR/config.json"

# Setup test environment
setup_test() {
    mkdir -p "$TEST_CONFIG_DIR"
    export XDG_CONFIG_HOME="$(dirname "$TEST_CONFIG_DIR")"
    # Override config file location for testing
    CONFIG_FILE="$TEST_CONFIG_DIR/config.json"
}

# Cleanup test environment
cleanup_test() {
    rm -rf "$TEST_CONFIG_DIR"
}

# Test: Initialize configuration
test_init_config() {
    echo "Testing: Config initialization..."
    
    if ! init_config; then
        echo "FAILED: Config initialization failed"
        return 1
    fi
    
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "FAILED: Config file not created"
        return 1
    fi
    
    echo "PASSED: Config initialization"
    return 0
}

# Test: Get configuration values
test_get_config() {
    echo "Testing: Get config values..."
    
    local pds
    pds=$(get_config "pds_endpoint")
    if [ "$pds" != "https://bsky.social" ]; then
        echo "FAILED: Expected default PDS, got: $pds"
        return 1
    fi
    
    local format
    format=$(get_config "output_format")
    if [ "$format" != "text" ]; then
        echo "FAILED: Expected 'text' format, got: $format"
        return 1
    fi
    
    echo "PASSED: Get config values"
    return 0
}

# Test: Set configuration values
test_set_config() {
    echo "Testing: Set config values..."
    
    # Test setting feed limit
    if ! set_config "feed_limit" "30"; then
        echo "FAILED: Could not set feed_limit"
        return 1
    fi
    
    local limit
    limit=$(get_config "feed_limit")
    if [ "$limit" != "30" ]; then
        echo "FAILED: Expected 30, got: $limit"
        return 1
    fi
    
    # Test setting PDS endpoint
    if ! set_config "pds_endpoint" "https://test.bsky.social"; then
        echo "FAILED: Could not set pds_endpoint"
        return 1
    fi
    
    local pds
    pds=$(get_config "pds_endpoint")
    if [ "$pds" != "https://test.bsky.social" ]; then
        echo "FAILED: Expected test PDS, got: $pds"
        return 1
    fi
    
    echo "PASSED: Set config values"
    return 0
}

# Test: Validation of config values
test_validation() {
    echo "Testing: Config validation..."
    
    # Test invalid feed limit (too large)
    if set_config "feed_limit" "500" 2>/dev/null; then
        echo "FAILED: Should reject invalid feed limit"
        return 1
    fi
    
    # Test invalid output format
    if set_config "output_format" "xml" 2>/dev/null; then
        echo "FAILED: Should reject invalid output format"
        return 1
    fi
    
    # Test invalid PDS endpoint
    if set_config "pds_endpoint" "not-a-url" 2>/dev/null; then
        echo "FAILED: Should reject invalid PDS endpoint"
        return 1
    fi
    
    # Test invalid boolean
    if set_config "debug" "maybe" 2>/dev/null; then
        echo "FAILED: Should reject invalid boolean value"
        return 1
    fi
    
    echo "PASSED: Config validation"
    return 0
}

# Test: Reset configuration
test_reset_config() {
    echo "Testing: Config reset..."
    
    # Change a value
    set_config "feed_limit" "75" >/dev/null 2>&1
    
    # Reset config (suppress output)
    if ! reset_config >/dev/null 2>&1; then
        echo "FAILED: Config reset failed"
        return 1
    fi
    
    # Verify default restored
    local limit
    limit=$(get_config "feed_limit")
    if [ "$limit" != "20" ]; then
        echo "FAILED: Expected default 20, got: $limit"
        return 1
    fi
    
    echo "PASSED: Config reset"
    return 0
}

# Test: List configuration
test_list_config() {
    echo "Testing: Config list..."
    
    if ! list_config >/dev/null; then
        echo "FAILED: list_config failed"
        return 1
    fi
    
    echo "PASSED: Config list"
    return 0
}

# Test: Validate configuration file
test_validate_config() {
    echo "Testing: Config validation..."
    
    if ! validate_config >/dev/null; then
        echo "FAILED: Valid config reported as invalid"
        return 1
    fi
    
    echo "PASSED: Config validation"
    return 0
}

# Test: Environment variable override
test_env_override() {
    echo "Testing: Environment variable override..."
    
    # Set config value
    set_config "pds_endpoint" "https://config.bsky.social" >/dev/null 2>&1
    
    # Set environment variable
    export ATP_PDS="https://env.bsky.social"
    
    # get_effective_config should prefer env var
    local pds
    pds=$(get_effective_config "pds_endpoint" "ATP_PDS")
    
    if [ "$pds" != "https://env.bsky.social" ]; then
        echo "FAILED: Expected env var value, got: $pds"
        return 1
    fi
    
    unset ATP_PDS
    
    echo "PASSED: Environment variable override"
    return 0
}

# Main test execution
main() {
    echo "================================"
    echo "AT-bot Configuration Tests"
    echo "================================"
    echo ""
    
    setup_test
    
    local failed=0
    
    test_init_config || failed=$((failed + 1))
    test_get_config || failed=$((failed + 1))
    test_set_config || failed=$((failed + 1))
    test_validation || failed=$((failed + 1))
    test_reset_config || failed=$((failed + 1))
    test_list_config || failed=$((failed + 1))
    test_validate_config || failed=$((failed + 1))
    test_env_override || failed=$((failed + 1))
    
    cleanup_test
    
    echo ""
    echo "================================"
    if [ $failed -eq 0 ]; then
        echo "All configuration tests passed!"
        echo "================================"
        exit 0
    else
        echo "Configuration tests failed: $failed"
        echo "================================"
        exit 1
    fi
}

main "$@"
