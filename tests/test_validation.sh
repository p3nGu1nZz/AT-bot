#!/bin/bash
# Test suite for validation library

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Source test dependencies
source "$PROJECT_ROOT/lib/reporter.sh"
source "$PROJECT_ROOT/lib/validation.sh"

echo "Testing validation library..."
echo ""

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test helper
run_test() {
    local test_name="$1"
    local expected_result="$2"  # 0 for success, 1 for failure
    shift 2
    local command="$@"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if eval "$command" >/dev/null 2>&1; then
        actual_result=0
    else
        actual_result=1
    fi
    
    if [ "$actual_result" -eq "$expected_result" ]; then
        echo "✓ $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "✗ $test_name"
        echo "  Expected: $expected_result, Got: $actual_result"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Test post text validation
echo "Post Text Validation:"
run_test "Empty text fails" 1 validate_post_text ""
run_test "Normal text passes" 0 validate_post_text "Hello world"
run_test "Text with emoji passes" 0 validate_post_text "Hello 🎉 world"
run_test "300 char text passes" 0 validate_post_text "$(printf 'a%.0s' {1..300})"
run_test "Very long text fails" 1 validate_post_text "$(printf 'a%.0s' {1..4000})"
echo ""

# Test handle validation
echo "Handle Validation:"
run_test "Empty handle fails" 1 validate_handle ""
run_test "Valid handle passes" 0 validate_handle "user.bsky.social"
run_test "Handle with @ passes" 0 validate_handle "@user.bsky.social"
run_test "No domain fails" 1 validate_handle "user"
run_test "Invalid chars fail" 1 validate_handle "user@bsky.social"
run_test "Subdomain passes" 0 validate_handle "user.subdomain.bsky.social"
echo ""

# Test AT-URI validation
echo "AT-URI Validation:"
run_test "Empty URI fails" 1 validate_at_uri ""
run_test "Valid URI passes" 0 validate_at_uri "at://did:plc:abc123/app.bsky.feed.post/xyz789"
run_test "Invalid format fails" 1 validate_at_uri "https://example.com"
run_test "Missing collection fails" 1 validate_at_uri "at://did:plc:abc123"
echo ""

# Test DID validation
echo "DID Validation:"
run_test "Empty DID fails" 1 validate_did ""
run_test "Valid PLC DID passes" 0 validate_did "did:plc:abc123xyz"
run_test "Valid Web DID passes" 0 validate_did "did:web:example"
run_test "Invalid format fails" 1 validate_did "not-a-did"
echo ""

# Test image file validation
echo "Image File Validation:"
run_test "Empty path fails" 1 validate_image_file ""
run_test "Non-existent file fails" 1 validate_image_file "/nonexistent/file.jpg"
# Note: We can't test valid files without creating them
echo ""

# Test limit validation
echo "Limit Validation:"
run_test "Empty limit passes" 0 validate_limit ""
run_test "Valid limit passes" 0 validate_limit "10"
run_test "Zero limit fails" 1 validate_limit "0"
run_test "Negative limit fails" 1 validate_limit "-5"
run_test "Non-numeric fails" 1 validate_limit "abc"
run_test "Exceeds max fails" 1 validate_limit "200" "100"
echo ""

# Test URL validation
echo "URL Validation:"
run_test "Empty URL fails" 1 validate_url ""
run_test "HTTP URL passes" 0 validate_url "http://example.com"
run_test "HTTPS URL passes" 0 validate_url "https://example.com/path"
run_test "Invalid protocol fails" 1 validate_url "ftp://example.com"
run_test "No protocol fails" 1 validate_url "example.com"
echo ""

# Test email validation
echo "Email Validation:"
run_test "Empty email fails" 1 validate_email ""
run_test "Valid email passes" 0 validate_email "user@example.com"
run_test "Email with subdomain passes" 0 validate_email "user@mail.example.com"
run_test "No @ fails" 1 validate_email "userexample.com"
run_test "No domain fails" 1 validate_email "user@"
echo ""

# Test identifier validation
echo "Identifier Validation:"
run_test "Empty identifier fails" 1 validate_identifier ""
run_test "Valid handle identifier passes" 0 validate_identifier "user.bsky.social"
run_test "Valid email identifier passes" 0 validate_identifier "user@example.com"
run_test "Invalid identifier fails" 1 validate_identifier "not-valid"
echo ""

# Summary
echo "======================================"
echo "Test Results:"
echo "  Total:  $TESTS_RUN"
echo "  Passed: $TESTS_PASSED"
echo "  Failed: $TESTS_FAILED"
echo "======================================"

if [ $TESTS_FAILED -eq 0 ]; then
    echo "✓ All tests passed!"
    exit 0
else
    echo "✗ Some tests failed"
    exit 1
fi
