#!/bin/bash
# Test mention detection and facet generation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Source the library
source "$PROJECT_ROOT/lib/atproto.sh"

echo "Testing mention facet generation..."
echo

# Test 1: Single mention
echo "Test 1: Single mention"
text1="Hello @alice.bsky.social"
facets1=$(create_mention_facets "$text1")
echo "Text: $text1"
echo "Facets: $facets1"
echo

# Test 2: Multiple mentions
echo "Test 2: Multiple mentions"
text2="Hey @bob.bsky.social and @charlie.example.com"
facets2=$(create_mention_facets "$text2")
echo "Text: $text2"
echo "Facets: $facets2"
echo

# Test 3: Mentions with subdomains
echo "Test 3: Mentions with subdomains"
text3="Mentioning @user.subdomain.bsky.social here"
facets3=$(create_mention_facets "$text3")
echo "Text: $text3"
echo "Facets: $facets3"
echo

# Test 4: Mixed with hashtags (hashtags should be handled separately)
echo "Test 4: Mentions and hashtags together"
text4="Check out @p3ngu1nzz.bsky.social for #atproto #Bluesky"
mention_facets=$(create_mention_facets "$text4")
hashtag_facets=$(create_hashtag_facets "$text4")
combined_facets=$(merge_facets "$mention_facets" "$hashtag_facets")
echo "Text: $text4"
echo "Mention facets:"
echo "$mention_facets" | head -15
echo "Hashtag facets:"
echo "$hashtag_facets" | head -15
echo "Combined facets:"
echo "$combined_facets" | head -30
echo

# Test 5: No valid mentions (missing domain)
echo "Test 5: Invalid mentions (no domain)"
text5="Just @username without domain"
facets5=$(create_mention_facets "$text5")
echo "Text: $text5"
echo "Facets: $facets5"
echo

# Test 6: Email addresses should not be detected
echo "Test 6: Email addresses (should not match)"
text6="Email me at test@example.com"
facets6=$(create_mention_facets "$text6")
echo "Text: $text6"
echo "Facets: $facets6"
echo

# Test 7: Multiple occurrences of same mention
echo "Test 7: Repeated mentions"
text7="@alice.bsky.social said hi to @alice.bsky.social"
facets7=$(create_mention_facets "$text7")
echo "Text: $text7"
echo "Facets:"
echo "$facets7" | head -20
echo

echo "All tests completed!"
echo
echo "Note: Mention facets use placeholder DIDs. In production,"
echo "      these would be resolved to actual DIDs via API."
