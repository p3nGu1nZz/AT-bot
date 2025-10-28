#!/bin/bash
# Manual testing helper for AT-bot
# This script helps you test AT-bot interactively with your credentials

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
AT_BOT="$PROJECT_ROOT/bin/at-bot"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}AT-bot Manual Test Helper${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# Check if logged in
if [ -f ~/.config/at-bot/session.json ]; then
    echo -e "${GREEN}✓ Already logged in${NC}"
    "$AT_BOT" whoami
    echo ""
else
    echo -e "${YELLOW}Not logged in. Running login...${NC}"
    echo ""
    "$AT_BOT" login
    echo ""
fi

# Menu
while true; do
    echo -e "${BLUE}What would you like to test?${NC}"
    echo "1) Create a test post"
    echo "2) Read your feed"
    echo "3) Check who you are (whoami)"
    echo "4) Logout"
    echo "5) Clear saved credentials"
    echo "6) Exit"
    echo ""
    read -r -p "Choice: " choice
    
    case $choice in
        1)
            echo ""
            read -r -p "Enter post text: " post_text
            "$AT_BOT" post "$post_text"
            echo ""
            ;;
        2)
            echo ""
            read -r -p "How many posts? (default 10): " limit
            limit=${limit:-10}
            "$AT_BOT" feed "$limit"
            echo ""
            ;;
        3)
            echo ""
            "$AT_BOT" whoami
            echo ""
            ;;
        4)
            echo ""
            "$AT_BOT" logout
            echo ""
            break
            ;;
        5)
            echo ""
            "$AT_BOT" clear-credentials
            echo ""
            ;;
        6)
            echo "Goodbye!"
            exit 0
            ;;
        *)
            echo -e "${YELLOW}Invalid choice${NC}"
            echo ""
            ;;
    esac
done
