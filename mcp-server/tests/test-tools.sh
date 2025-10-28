#!/bin/bash
# MCP Tool Integration Tests - Simplified Version
# Validates that all MCP tools are properly compiled and registered

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
MCP_SERVER_DIR="$PROJECT_ROOT/mcp-server"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo "================================"
echo "MCP Tool Integration Tests"
echo "================================"
echo ""

# Check if dist exists
if [ ! -d "$MCP_SERVER_DIR/dist/tools" ]; then
    echo -e "${RED}✗ Error: dist/tools directory not found${NC}"
    echo "Build MCP server first: cd $MCP_SERVER_DIR && npm run build"
    exit 1
fi

# Count tools in each module
count_tools() {
    local file="$1"
    grep -c "name: '" "$file" 2>/dev/null || echo "0"
}

echo -e "${YELLOW}Tool Module Summary:${NC}"
echo ""

# Authentication tools
AUTH_COUNT=$(count_tools "$MCP_SERVER_DIR/dist/tools/auth-tools.js")
echo -e "  ${GREEN}✓${NC} Authentication tools: ${YELLOW}$AUTH_COUNT${NC} tools"

# Engagement tools
if [ -f "$MCP_SERVER_DIR/dist/tools/engagement-tools.js" ]; then
    ENGAGE_COUNT=$(count_tools "$MCP_SERVER_DIR/dist/tools/engagement-tools.js")
    echo -e "  ${GREEN}✓${NC} Engagement tools:     ${YELLOW}$ENGAGE_COUNT${NC} tools"
else
    echo -e "  ${RED}✗${NC} Engagement tools:     ${RED}NOT FOUND${NC}"
    ENGAGE_COUNT=0
fi

# Social tools
if [ -f "$MCP_SERVER_DIR/dist/tools/social-tools.js" ]; then
    SOCIAL_COUNT=$(count_tools "$MCP_SERVER_DIR/dist/tools/social-tools.js")
    echo -e "  ${GREEN}✓${NC} Social tools:         ${YELLOW}$SOCIAL_COUNT${NC} tools"
else
    echo -e "  ${RED}✗${NC} Social tools:         ${RED}NOT FOUND${NC}"
    SOCIAL_COUNT=0
fi

# Search tools
if [ -f "$MCP_SERVER_DIR/dist/tools/search-tools.js" ]; then
    SEARCH_COUNT=$(count_tools "$MCP_SERVER_DIR/dist/tools/search-tools.js")
    echo -e "  ${GREEN}✓${NC} Search tools:         ${YELLOW}$SEARCH_COUNT${NC} tools"
else
    echo -e "  ${RED}✗${NC} Search tools:         ${RED}NOT FOUND${NC}"
    SEARCH_COUNT=0
fi

# Media tools
if [ -f "$MCP_SERVER_DIR/dist/tools/media-tools.js" ]; then
    MEDIA_COUNT=$(count_tools "$MCP_SERVER_DIR/dist/tools/media-tools.js")
    echo -e "  ${GREEN}✓${NC} Media tools:          ${YELLOW}$MEDIA_COUNT${NC} tools"
else
    echo -e "  ${RED}✗${NC} Media tools:          ${RED}NOT FOUND${NC}"
    MEDIA_COUNT=0
fi

# Feed tools
if [ -f "$MCP_SERVER_DIR/dist/tools/feed-tools.js" ]; then
    FEED_COUNT=$(count_tools "$MCP_SERVER_DIR/dist/tools/feed-tools.js")
    echo -e "  ${GREEN}✓${NC} Feed tools:           ${YELLOW}$FEED_COUNT${NC} tools"
else
    echo -e "  ${RED}✗${NC} Feed tools:           ${RED}NOT FOUND${NC}"
    FEED_COUNT=0
fi

# Profile tools
if [ -f "$MCP_SERVER_DIR/dist/tools/profile-tools.js" ]; then
    PROFILE_COUNT=$(count_tools "$MCP_SERVER_DIR/dist/tools/profile-tools.js")
    echo -e "  ${GREEN}✓${NC} Profile tools:        ${YELLOW}$PROFILE_COUNT${NC} tools"
else
    echo -e "  ${RED}✗${NC} Profile tools:        ${RED}NOT FOUND${NC}"
    PROFILE_COUNT=0
fi

# Calculate totals
TOTAL=$((AUTH_COUNT + ENGAGE_COUNT + SOCIAL_COUNT + SEARCH_COUNT + MEDIA_COUNT + FEED_COUNT + PROFILE_COUNT))

echo ""
echo "================================"
echo -e "Total tools compiled: ${GREEN}$TOTAL${NC}"
echo "Expected: 22+ tools"
echo "================================"

# Test MCP server registration
echo ""
echo -e "${YELLOW}MCP Server Registration Check:${NC}"
echo ""

if [ -f "$MCP_SERVER_DIR/dist/index.js" ]; then
    echo -e "  ${GREEN}✓${NC} index.js exists"
    
    # Check for tool arrays in index
    if grep -q "engagementTools\|engagement" "$MCP_SERVER_DIR/dist/index.js"; then
        echo -e "  ${GREEN}✓${NC} Engagement tools registered"
    else
        echo -e "  ${YELLOW}!${NC} Engagement tools registration unclear"
    fi
    
    if grep -q "socialTools\|social" "$MCP_SERVER_DIR/dist/index.js"; then
        echo -e "  ${GREEN}✓${NC} Social tools registered"
    else
        echo -e "  ${YELLOW}!${NC} Social tools registration unclear"
    fi
else
    echo -e "  ${RED}✗${NC} index.js NOT FOUND - build required"
fi

echo ""
echo "================================"
if [ $TOTAL -ge 22 ]; then
    echo -e "${GREEN}✓ All tools compiled successfully!${NC}"
    exit 0
else
    echo -e "${YELLOW}! Tool count lower than expected (got $TOTAL, expected 22+)${NC}"
    exit 1
fi
