#!/bin/bash
# Test hashtag detection and facet generation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Source the library
source "$PROJECT_ROOT/lib/atproto.sh"

echo "Testing hashtag facet generation..."
echo

# Test 1: Single hashtag
echo "Test 1: Single hashtag"
text1="Hello #world"
facets1=$(create_hashtag_facets "$text1")
echo "Text: $text1"
echo "Facets: $facets1"
echo

# Test 2: Multiple hashtags
echo "Test 2: Multiple hashtags"
text2="Testing #MCP #ATProtocol #Bluesky"
facets2=$(create_hashtag_facets "$text2")
echo "Text: $text2"
echo "Facets: $facets2"
echo

# Test 3: Hashtags with underscores and hyphens
echo "Test 3: Hashtags with underscores and hyphens"
text3="Check out #Open_Source and #AI-Tools"
facets3=$(create_hashtag_facets "$text3")
echo "Text: $text3"
echo "Facets: $facets3"
echo

# Test 4: Complex post (like your MCP announcement)
echo "Test 4: Complex post with multiple hashtags"
text4="atproto MCP Server is live! Model Context Protocol for AT Protocol/Bluesky. AI agents can now interact with Bluesky! 29 tools, VS Code extension, open source. #MCP #ATProtocol #Bluesky #AI #OpenSource #DevTools #VSCode"
facets4=$(create_hashtag_facets "$text4")
echo "Text: $text4"
echo "Facets:"
echo "$facets4" | head -20
echo "..."
echo

# Test 5: No hashtags
echo "Test 5: No hashtags"
text5="Just a regular post"
facets5=$(create_hashtag_facets "$text5")
echo "Text: $text5"
echo "Facets: $facets5"
echo

echo "All tests completed!"
