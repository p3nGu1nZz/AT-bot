#!/bin/bash
# Example: Automated content curation using JSON output
# Demonstrates how JSON output enables powerful automation

set -e

echo "🤖 AT-bot Automation Example"
echo "============================="
echo ""

# Ensure JSON output
export ATP_OUTPUT_FORMAT=json
export ATP_COLOR_OUTPUT=never

# Check if logged in
echo "Checking authentication..."
if at-bot whoami 2>/dev/null | jq -e '.status == "authenticated"' > /dev/null; then
    HANDLE=$(at-bot whoami | jq -r '.handle')
    echo "✅ Authenticated as: $HANDLE"
else
    echo "❌ Not logged in. Please run: at-bot login"
    exit 1
fi
echo ""

# Example 1: Search and curate content
echo "Example 1: Content Curation"
echo "----------------------------"
echo "Searching for 'AT Protocol' posts..."

SEARCH_RESULTS=$(at-bot search "AT Protocol" 5)
POST_COUNT=$(echo "$SEARCH_RESULTS" | jq '.posts | length')

echo "Found $POST_COUNT posts"
echo ""

# Show first post
if [ "$POST_COUNT" -gt 0 ]; then
    FIRST_POST=$(echo "$SEARCH_RESULTS" | jq -r '.posts[0]')
    POST_TEXT=$(echo "$FIRST_POST" | jq -r '.record.text' | head -c 60)
    POST_URI=$(echo "$FIRST_POST" | jq -r '.uri')
    
    echo "First result:"
    echo "  Text: ${POST_TEXT}..."
    echo "  URI: $POST_URI"
    echo ""
fi

# Example 2: Create post and capture details
echo "Example 2: Post Creation & Tracking"
echo "------------------------------------"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M")
POST_TEXT="🤖 Automated post created at $TIMESTAMP via AT-bot"

echo "Creating post: $POST_TEXT"
POST_RESULT=$(at-bot post "$POST_TEXT")

POST_URI=$(echo "$POST_RESULT" | jq -r '.uri')
POST_CID=$(echo "$POST_RESULT" | jq -r '.cid')

echo "✅ Post created successfully!"
echo "  URI: $POST_URI"
echo "  CID: $POST_CID"
echo ""

# Save to log file
LOG_FILE="automation.log"
echo "$TIMESTAMP | $POST_URI | $POST_CID" >> "$LOG_FILE"
echo "📝 Logged to: $LOG_FILE"
echo ""

# Example 3: Feed analysis
echo "Example 3: Feed Analysis"
echo "------------------------"
echo "Analyzing your feed..."

FEED=$(at-bot feed 10)
FEED_COUNT=$(echo "$FEED" | jq '.feed | length')

echo "Retrieved $FEED_COUNT posts from your feed"

# Count posts by type
if [ "$FEED_COUNT" -gt 0 ]; then
    # Simple text length analysis
    AVG_LENGTH=$(echo "$FEED" | jq '[.feed[].post.record.text | length] | add / length' 2>/dev/null || echo "0")
    echo "  Average post length: ${AVG_LENGTH} characters"
fi
echo ""

echo "============================="
echo "✅ Automation examples complete!"
echo ""
echo "This script demonstrates:"
echo "  • JSON output for easy parsing"
echo "  • Automated authentication check"
echo "  • Content search and extraction"
echo "  • Post creation with result tracking"
echo "  • Feed data analysis"
echo ""
echo "Build your own automations using these patterns!"
