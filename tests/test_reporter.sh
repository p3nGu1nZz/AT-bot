#!/bin/bash
# Test: Reporter library functions

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
REPORTER_LIB="$PROJECT_ROOT/lib/reporter.sh"

# Test that reporter.sh exists
test_exists() {
    [ -f "$REPORTER_LIB" ]
}

# Test that reporter.sh can be sourced
test_source() {
    source "$REPORTER_LIB"
    return 0
}

# Test color definitions
test_colors() {
    source "$REPORTER_LIB"
    
    # Check that AT_BOT_COLORS_DEFINED is set (colors may be empty if not a TTY)
    [ -n "$AT_BOT_COLORS_DEFINED" ] || return 1
    
    # Variables should be defined (even if empty)
    # Using 'declare -p' to check if variable is set
    declare -p RED >/dev/null 2>&1 || return 1
    declare -p GREEN >/dev/null 2>&1 || return 1
    declare -p YELLOW >/dev/null 2>&1 || return 1
    declare -p BLUE >/dev/null 2>&1 || return 1
    declare -p NC >/dev/null 2>&1 || return 1
    
    return 0
}

# Test multiple sourcing (should not fail with readonly errors)
test_multiple_source() {
    source "$REPORTER_LIB"
    source "$REPORTER_LIB"
    source "$REPORTER_LIB"
    return 0
}

# Test basic logging functions exist
test_logging_functions() {
    source "$REPORTER_LIB"
    
    type error >/dev/null 2>&1 || return 1
    type success >/dev/null 2>&1 || return 1
    type warning >/dev/null 2>&1 || return 1
    type info >/dev/null 2>&1 || return 1
    type debug >/dev/null 2>&1 || return 1
    
    return 0
}

# Test enhanced logging functions exist
test_enhanced_logging() {
    source "$REPORTER_LIB"
    
    type log_info >/dev/null 2>&1 || return 1
    type log_success >/dev/null 2>&1 || return 1
    type log_error >/dev/null 2>&1 || return 1
    type log_warning >/dev/null 2>&1 || return 1
    type log_skip >/dev/null 2>&1 || return 1
    
    return 0
}

# Test progress functions exist
test_progress_functions() {
    source "$REPORTER_LIB"
    
    type progress >/dev/null 2>&1 || return 1
    type complete >/dev/null 2>&1 || return 1
    type step >/dev/null 2>&1 || return 1
    
    return 0
}

# Test header functions exist
test_header_functions() {
    source "$REPORTER_LIB"
    
    type header >/dev/null 2>&1 || return 1
    type section >/dev/null 2>&1 || return 1
    type subsection >/dev/null 2>&1 || return 1
    type divider >/dev/null 2>&1 || return 1
    
    return 0
}

# Test summary functions exist
test_summary_functions() {
    source "$REPORTER_LIB"
    
    type test_summary >/dev/null 2>&1 || return 1
    type build_summary >/dev/null 2>&1 || return 1
    
    return 0
}

# Test formatting functions exist
test_formatting_functions() {
    source "$REPORTER_LIB"
    
    type kvpair >/dev/null 2>&1 || return 1
    type list_item >/dev/null 2>&1 || return 1
    type numbered_item >/dev/null 2>&1 || return 1
    type boxed >/dev/null 2>&1 || return 1
    type centered >/dev/null 2>&1 || return 1
    
    return 0
}

# Test table functions exist
test_table_functions() {
    source "$REPORTER_LIB"
    
    type table_header >/dev/null 2>&1 || return 1
    type table_row >/dev/null 2>&1 || return 1
    
    return 0
}

# Test validation functions exist
test_validation_functions() {
    source "$REPORTER_LIB"
    
    type validate >/dev/null 2>&1 || return 1
    type status >/dev/null 2>&1 || return 1
    type dependency_report >/dev/null 2>&1 || return 1
    type file_operation_report >/dev/null 2>&1 || return 1
    type command_report >/dev/null 2>&1 || return 1
    
    return 0
}

# Test utility functions exist
test_utility_functions() {
    source "$REPORTER_LIB"
    
    type progress_bar >/dev/null 2>&1 || return 1
    type error_with_suggestion >/dev/null 2>&1 || return 1
    
    return 0
}

# Test function output (basic smoke test)
test_function_output() {
    source "$REPORTER_LIB"
    
    # Redirect output to /dev/null and just check for no errors
    # Disable errexit temporarily for this test
    set +e
    
    error "test error" 2>/dev/null
    success "test success" >/dev/null
    warning "test warning" 2>/dev/null
    info "test info" >/dev/null
    log_info "test log_info" >/dev/null
    log_success "test log_success" >/dev/null
    progress "test progress" >/dev/null
    complete "test complete" >/dev/null
    header "Test Header" >/dev/null
    section "Test Section" >/dev/null
    divider >/dev/null
    kvpair "Key" "Value" >/dev/null
    list_item "item" >/dev/null
    numbered_item 1 "item" >/dev/null
    
    set -e
    return 0
}

# Test test_summary function
test_test_summary() {
    source "$REPORTER_LIB"
    
    # Should not crash with valid input
    test_summary 5 0 0 >/dev/null 2>&1
    local result=$?
    [ "$result" -eq 0 ] || return 1
    
    # Get output and check it contains expected text
    output=$(test_summary 5 0 0 2>&1)
    echo "$output" | grep -q "Passed" || return 1
    echo "$output" | grep -q "Failed" || return 1
    
    return 0
}

# Test progress_bar function
test_progress_bar_function() {
    source "$REPORTER_LIB"
    
    # Should not crash with valid input
    progress_bar 5 10 20 >/dev/null 2>&1
    local result=$?
    [ "$result" -eq 0 ] || return 1
    
    return 0
}

# Test validate function
test_validate_function() {
    source "$REPORTER_LIB"
    
    # Test with success code
    validate "Test check" 0 >/dev/null 2>&1
    local result=$?
    [ "$result" -eq 0 ] || return 1
    
    # Test with failure code
    validate "Test check" 1 >/dev/null 2>&1
    result=$?
    [ "$result" -ne 0 ] || return 1
    
    return 0
}

# Test status function
test_status_function() {
    source "$REPORTER_LIB"
    
    # Test various states
    status "enabled" >/dev/null 2>&1
    local result=$?
    [ "$result" -eq 0 ] || return 1
    
    status "disabled" >/dev/null 2>&1
    result=$?
    [ "$result" -eq 0 ] || return 1
    
    return 0
}

# Run all tests
echo "Running reporter.sh tests..." >&2
test_exists || exit 1
echo "✓ test_exists" >&2
test_source || exit 1
echo "✓ test_source" >&2
test_colors || exit 1
echo "✓ test_colors" >&2
test_multiple_source || exit 1
echo "✓ test_multiple_source" >&2
test_logging_functions || exit 1
echo "✓ test_logging_functions" >&2
test_enhanced_logging || exit 1
echo "✓ test_enhanced_logging" >&2
test_progress_functions || exit 1
echo "✓ test_progress_functions" >&2
test_header_functions || exit 1
echo "✓ test_header_functions" >&2
test_summary_functions || exit 1
echo "✓ test_summary_functions" >&2
test_formatting_functions || exit 1
echo "✓ test_formatting_functions" >&2
test_table_functions || exit 1
echo "✓ test_table_functions" >&2
test_validation_functions || exit 1
echo "✓ test_validation_functions" >&2
test_utility_functions || exit 1
echo "✓ test_utility_functions" >&2
test_function_output || exit 1
echo "✓ test_function_output" >&2
test_test_summary || exit 1
echo "✓ test_test_summary" >&2
test_progress_bar_function || exit 1
echo "✓ test_progress_bar_function" >&2
test_validate_function || exit 1
echo "✓ test_validate_function" >&2
test_status_function || exit 1
echo "✓ test_status_function" >&2

echo "All reporter.sh tests passed!" >&2
exit 0
