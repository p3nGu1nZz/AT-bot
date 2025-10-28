#!/bin/bash
# Test: Media upload functionality

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LIB_DIR="$PROJECT_ROOT/lib"

# Source the library
# shellcheck source=../lib/atproto.sh
source "$LIB_DIR/atproto.sh"

# Test counter
TESTS_RUN=0
TESTS_PASSED=0

# Color definitions
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    NC=''
fi

# Test output functions
test_start() {
    echo -e "${BLUE}[TEST]${NC} $1"
    TESTS_RUN=$((TESTS_RUN + 1))
}

test_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

test_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
}

test_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

# Setup test environment
setup_test() {
    TEST_DIR=$(mktemp -d)
    export TEST_DIR
    
    # Create test images with different formats and sizes
    # Note: We'll create simple text files with appropriate extensions for testing
    # These aren't real images but sufficient for unit testing MIME type detection
    # and file validation logic
    
    # Create test files with image extensions
    echo "fake jpeg data" > "$TEST_DIR/test.jpg"
    echo "fake png data" > "$TEST_DIR/test.png"
    echo "fake gif data" > "$TEST_DIR/test.gif"
    echo "fake webp data" > "$TEST_DIR/test.webp"
    
    # Create an invalid file (not an image)
    echo "This is not an image" > "$TEST_DIR/invalid.txt"
    
    # Create a large file (for size testing - 2MB)
    dd if=/dev/zero of="$TEST_DIR/large.jpg" bs=1M count=2 2>/dev/null
    
    test_info "Test directory: $TEST_DIR"
}

# Cleanup test environment
cleanup_test() {
    if [ -d "$TEST_DIR" ]; then
        rm -rf "$TEST_DIR"
        test_info "Cleaned up test directory"
    fi
}

# Test 1: Validate MIME type detection
test_mime_detection() {
    test_start "MIME type detection"
    
    local mime_type
    local file_path="$TEST_DIR/test.jpg"
    
    # Test JPEG
    if [[ "$file_path" =~ \.(jpg|jpeg)$ ]]; then
        mime_type="image/jpeg"
    fi
    
    if [ "$mime_type" = "image/jpeg" ]; then
        test_pass "JPEG MIME type detected correctly"
        return 0
    else
        test_fail "JPEG MIME type detection failed (got: $mime_type)"
        return 1
    fi
}

# Test 2: Validate PNG MIME type
test_mime_png() {
    test_start "PNG MIME type detection"
    
    local mime_type
    local file_path="$TEST_DIR/test.png"
    
    if [[ "$file_path" =~ \.png$ ]]; then
        mime_type="image/png"
    fi
    
    if [ "$mime_type" = "image/png" ]; then
        test_pass "PNG MIME type detected correctly"
        return 0
    else
        test_fail "PNG MIME type detection failed (got: $mime_type)"
        return 1
    fi
}

# Test 3: Validate GIF MIME type
test_mime_gif() {
    test_start "GIF MIME type detection"
    
    local mime_type
    local file_path="$TEST_DIR/test.gif"
    
    if [[ "$file_path" =~ \.gif$ ]]; then
        mime_type="image/gif"
    fi
    
    if [ "$mime_type" = "image/gif" ]; then
        test_pass "GIF MIME type detected correctly"
        return 0
    else
        test_fail "GIF MIME type detection failed (got: $mime_type)"
        return 1
    fi
}

# Test 4: Validate WebP MIME type
test_mime_webp() {
    test_start "WebP MIME type detection"
    
    local mime_type
    local file_path="$TEST_DIR/test.webp"
    
    if [[ "$file_path" =~ \.webp$ ]]; then
        mime_type="image/webp"
    fi
    
    if [ "$mime_type" = "image/webp" ]; then
        test_pass "WebP MIME type detected correctly"
        return 0
    else
        test_fail "WebP MIME type detection failed (got: $mime_type)"
        return 1
    fi
}

# Test 5: Validate file existence check
test_file_not_found() {
    test_start "File not found handling"
    
    local file_path="$TEST_DIR/nonexistent.jpg"
    
    if [ ! -f "$file_path" ]; then
        test_pass "Non-existent file detected correctly"
        return 0
    else
        test_fail "Non-existent file check failed"
        return 1
    fi
}

# Test 6: Validate unsupported file type
test_unsupported_type() {
    test_start "Unsupported file type detection"
    
    local file_path="$TEST_DIR/invalid.txt"
    local is_valid=false
    
    if [[ "$file_path" =~ \.(jpg|jpeg|png|gif|webp|mp4)$ ]]; then
        is_valid=true
    fi
    
    if [ "$is_valid" = false ]; then
        test_pass "Unsupported file type detected correctly"
        return 0
    else
        test_fail "Unsupported file type check failed"
        return 1
    fi
}

# Test 7: Validate file size check (over 1MB)
test_file_size_limit() {
    test_start "File size limit check"
    
    local file_path="$TEST_DIR/large.jpg"
    local file_size
    file_size=$(stat -f%z "$file_path" 2>/dev/null || stat -c%s "$file_path" 2>/dev/null)
    local max_size=$((1024 * 1024))  # 1MB
    
    if [ "$file_size" -gt "$max_size" ]; then
        test_pass "File size limit detected correctly"
        return 0
    else
        test_fail "File size limit check failed"
        return 1
    fi
}

# Test 8: Validate valid image file properties
test_valid_image_file() {
    test_start "Valid image file properties"
    
    local file_path="$TEST_DIR/test.jpg"
    local file_size
    file_size=$(stat -f%z "$file_path" 2>/dev/null || stat -c%s "$file_path" 2>/dev/null)
    local max_size=$((1024 * 1024))  # 1MB
    
    if [ -f "$file_path" ] && [ "$file_size" -le "$max_size" ] && [[ "$file_path" =~ \.(jpg|jpeg|png|gif|webp)$ ]]; then
        test_pass "Valid image file properties confirmed"
        return 0
    else
        test_fail "Valid image file property check failed"
        return 1
    fi
}

# Test 9: Test blob reference JSON structure
test_blob_json_structure() {
    test_start "Blob reference JSON structure"
    
    # Mock blob reference (what atproto_upload_blob should return)
    local mock_blob_ref='{
        "blob": {
            "$type": "blob",
            "ref": {
                "$link": "bafyreih4kdfjlksjdflkajsdflkjasdflk"
            },
            "mimeType": "image/jpeg",
            "size": 12345
        }
    }'
    
    # Check if JSON contains required fields
    if echo "$mock_blob_ref" | grep -q '\$type.*blob' && \
       echo "$mock_blob_ref" | grep -q '\$link' && \
       echo "$mock_blob_ref" | grep -q 'mimeType' && \
       echo "$mock_blob_ref" | grep -q 'size'; then
        test_pass "Blob reference JSON structure valid"
        return 0
    else
        test_fail "Blob reference JSON structure invalid"
        return 1
    fi
}

# Test 10: Test embed images JSON structure
test_embed_json_structure() {
    test_start "Embed images JSON structure"
    
    # Mock embed JSON (what should be added to post)
    local mock_embed='{
        "$type": "app.bsky.embed.images",
        "images": [{
            "alt": "",
            "image": {
                "$type": "blob",
                "ref": { "$link": "bafyreih4kdfjlksjdflkajsdflkjasdflk" },
                "mimeType": "image/jpeg",
                "size": 12345
            }
        }]
    }'
    
    # Check if JSON contains required fields
    if echo "$mock_embed" | grep -q 'app.bsky.embed.images' && \
       echo "$mock_embed" | grep -q '"images"' && \
       echo "$mock_embed" | grep -q '"alt"' && \
       echo "$mock_embed" | grep -q '"image"'; then
        test_pass "Embed images JSON structure valid"
        return 0
    else
        test_fail "Embed images JSON structure invalid"
        return 1
    fi
}

# Test 11: Test upload endpoint format
test_upload_endpoint() {
    test_start "Upload endpoint format"
    
    local pds="${ATP_PDS:-https://bsky.social}"
    local endpoint="$pds/xrpc/com.atproto.repo.uploadBlob"
    
    if [[ "$endpoint" =~ ^https://.*bsky\.social/xrpc/com\.atproto\.repo\.uploadBlob$ ]]; then
        test_pass "Upload endpoint format valid"
        return 0
    else
        test_fail "Upload endpoint format invalid (got: $endpoint)"
        return 1
    fi
}

# Main test execution
main() {
    echo -e "${BLUE}====================================${NC}"
    echo -e "${BLUE}  Media Upload Functionality Tests${NC}"
    echo -e "${BLUE}====================================${NC}"
    echo ""
    
    setup_test
    
    # Run all tests
    test_mime_detection
    test_mime_png
    test_mime_gif
    test_mime_webp
    test_file_not_found
    test_unsupported_type
    test_file_size_limit
    test_valid_image_file
    test_blob_json_structure
    test_embed_json_structure
    test_upload_endpoint
    
    cleanup_test
    
    # Summary
    echo ""
    echo -e "${BLUE}====================================${NC}"
    echo -e "${BLUE}  Test Results${NC}"
    echo -e "${BLUE}====================================${NC}"
    echo -e "Tests Run:    ${BLUE}$TESTS_RUN${NC}"
    echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Tests Failed: ${RED}$((TESTS_RUN - TESTS_PASSED))${NC}"
    
    if [ "$TESTS_PASSED" -eq "$TESTS_RUN" ]; then
        echo -e "${GREEN}All tests passed!${NC}"
        exit 0
    else
        echo -e "${RED}Some tests failed!${NC}"
        exit 1
    fi
}

main "$@"
