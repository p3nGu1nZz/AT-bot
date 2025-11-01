#!/bin/bash
# Test URL facet detection
# This script tests the create_url_facets function

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Source the library
# shellcheck source=../lib/atproto.sh
source "$PROJECT_ROOT/lib/atproto.sh"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counter
TESTS=0
PASSED=0
FAILED=0

echo ""
echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   URL Facet Detection Test Suite    ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
echo ""

# Helper function to run a test
run_test() {
    local test_name="$1"
    local text="$2"
    local expected_count="$3"
    
    TESTS=$((TESTS + 1))
    echo -n "Test $TESTS: $test_name... "
    
    # Run function
    local facets
    facets=$(create_url_facets "$text")
    
    # Count facets (count opening braces of facet objects)
    local count
    count=$(echo "$facets" | grep -o '"byteStart"' | wc -l)
    
    if [ "$count" -eq "$expected_count" ]; then
        echo -e "${GREEN}✓ PASS${NC} (found $count URLs)"
        PASSED=$((PASSED + 1))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC} (expected $expected_count, found $count)"
        echo "  Text: $text"
        echo "  Facets: $facets"
        FAILED=$((FAILED + 1))
        return 1
    fi
}

# Test 1: Single HTTP URL
run_test "Single HTTP URL" \
    "Check out http://example.com for more info" \
    1

# Test 2: Single HTTPS URL
run_test "Single HTTPS URL" \
    "Visit https://github.com/p3nGu1nZz/atproto" \
    1

# Test 3: WWW URL (should be normalized to https://)
run_test "WWW URL normalization" \
    "Go to www.example.com for details" \
    1

# Test 4: Multiple URLs
run_test "Multiple URLs" \
    "Check https://github.com and https://bsky.app" \
    2

# Test 5: URLs with hashtags
run_test "URLs with hashtags" \
    "Visit https://example.com #link #url" \
    1

# Test 6: URL at start of text
run_test "URL at start" \
    "https://example.com is the site" \
    1

# Test 7: URL at end of text
run_test "URL at end" \
    "The site is https://example.com" \
    1

# Test 8: URL with path
run_test "URL with path" \
    "Check https://github.com/p3nGu1nZz/atproto/blob/main/README.md" \
    1

# Test 9: URL with query parameters
run_test "URL with query params" \
    "Search at https://example.com?q=test&lang=en" \
    1

# Test 10: No URLs
run_test "No URLs in text" \
    "This is plain text with no links" \
    0

# Test 11: Mixed URLs and www
run_test "Mixed HTTP/HTTPS/WWW" \
    "Sites: https://secure.example.com and www.example.org" \
    2

# Test 12: URL with fragment
run_test "URL with fragment" \
    "Anchor link: https://example.com/page#section" \
    1

# Summary
echo ""
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}Test Summary${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "Total Tests:  ${BLUE}$TESTS${NC}"
echo -e "Passed:       ${GREEN}$PASSED${NC}"
echo -e "Failed:       ${RED}$FAILED${NC}"

if [ $FAILED -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓ All tests passed!${NC}"
    echo ""
    exit 0
else
    echo ""
    echo -e "${RED}✗ Some tests failed${NC}"
    echo ""
    exit 1
fi
