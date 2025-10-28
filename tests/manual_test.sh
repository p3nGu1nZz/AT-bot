#!/bin/bash
# Comprehensive manual testing helper for AT-bot
# This script provides interactive testing of all major AT-bot features

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
AT_BOT="$PROJECT_ROOT/bin/at-bot"
CONFIG_DIR="$HOME/.config/at-bot"
SESSION_FILE="$CONFIG_DIR/session.json"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# Helper functions
print_section() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
}

print_test() {
    echo -e "${BLUE}▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
    ((TESTS_PASSED++))
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
    ((TESTS_FAILED++))
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
    ((TESTS_SKIPPED++))
}

press_enter() {
    echo ""
    read -r -p "Press Enter to continue..."
}

# Main menu
show_menu() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    echo -e "${BLUE}AT-bot Comprehensive Test Suite${NC}"
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    echo ""
    echo -e "${CYAN}Authentication Tests${NC}"
    echo "  1) Test login / create session"
    echo "  2) Test whoami (get current user)"
    echo "  3) Test session validation"
    echo ""
    echo -e "${CYAN}Content Tests${NC}"
    echo "  4) Create a simple post"
    echo "  5) Read your feed"
    echo "  6) Search posts"
    echo "  7) Search users"
    echo ""
    echo -e "${CYAN}Social Tests${NC}"
    echo "  8) Get profile information"
    echo "  9) View followers list"
    echo " 10) View following list"
    echo " 11) Follow a user"
    echo " 12) Unfollow a user"
    echo " 13) Block/unblock a user"
    echo " 14) Mute/unmute a user"
    echo ""
    echo -e "${CYAN}Advanced Tests${NC}"
    echo " 15) Test environment variables"
    echo " 16) Test help system"
    echo " 17) Run quick sanity tests"
    echo ""
    echo -e "${CYAN}Session Management${NC}"
    echo " 18) View session info"
    echo " 19) Logout"
    echo " 20) Clear saved credentials"
    echo ""
    echo -e "${CYAN}Exit${NC}"
    echo " 21) Exit test suite"
    echo ""
}

# Individual test functions
test_login() {
    print_section "Authentication: Login Test"
    
    if [ -f "$SESSION_FILE" ]; then
        print_warning "Session already exists. Use option 2 to verify it."
        return
    fi
    
    print_test "Attempting login..."
    if "$AT_BOT" login; then
        print_success "Login successful"
    else
        print_error "Login failed"
    fi
    
    press_enter
}

test_whoami() {
    print_section "Authentication: Whoami Test"
    
    if [ ! -f "$SESSION_FILE" ]; then
        print_warning "Not logged in. Please login first (option 1)."
        return
    fi
    
    print_test "Checking current user..."
    if output=$("$AT_BOT" whoami); then
        print_success "Whoami successful:"
        echo "$output"
    else
        print_error "Whoami failed"
    fi
    
    press_enter
}

test_session_validation() {
    print_section "Authentication: Session Validation Test"
    
    if [ ! -f "$SESSION_FILE" ]; then
        print_warning "Not logged in. Please login first (option 1)."
        return
    fi
    
    print_test "Validating session..."
    if output=$("$AT_BOT" validate-session 2>&1); then
        print_success "Session is valid"
        echo "$output"
    else
        print_warning "Session validation not implemented or expired"
    fi
    
    press_enter
}

test_post() {
    print_section "Content: Create Post Test"
    
    if [ ! -f "$SESSION_FILE" ]; then
        print_warning "Not logged in. Please login first (option 1)."
        return
    fi
    
    echo ""
    read -r -p "Enter post text (or press Enter to skip): " post_text
    
    if [ -z "$post_text" ]; then
        print_warning "Skipped post creation"
        return
    fi
    
    print_test "Creating post: '$post_text'"
    if "$AT_BOT" post "$post_text"; then
        print_success "Post created successfully"
    else
        print_error "Post creation failed"
    fi
    
    press_enter
}

test_feed() {
    print_section "Content: Read Feed Test"
    
    if [ ! -f "$SESSION_FILE" ]; then
        print_warning "Not logged in. Please login first (option 1)."
        return
    fi
    
    read -r -p "How many posts to fetch? (default 5): " limit
    limit=${limit:-5}
    
    print_test "Fetching $limit posts from your feed..."
    if "$AT_BOT" feed "$limit"; then
        print_success "Feed retrieval successful"
    else
        print_error "Feed retrieval failed"
    fi
    
    press_enter
}

test_search_posts() {
    print_section "Content: Search Posts Test"
    
    if [ ! -f "$SESSION_FILE" ]; then
        print_warning "Not logged in. Please login first (option 1)."
        return
    fi
    
    read -r -p "Enter search term for posts: " search_term
    
    if [ -z "$search_term" ]; then
        print_warning "Skipped post search"
        return
    fi
    
    print_test "Searching for posts: '$search_term'"
    if "$AT_BOT" search-posts "$search_term"; then
        print_success "Post search successful"
    else
        print_warning "Post search failed or no results"
    fi
    
    press_enter
}

test_search_users() {
    print_section "Content: Search Users Test"
    
    if [ ! -f "$SESSION_FILE" ]; then
        print_warning "Not logged in. Please login first (option 1)."
        return
    fi
    
    read -r -p "Enter search term for users: " search_term
    
    if [ -z "$search_term" ]; then
        print_warning "Skipped user search"
        return
    fi
    
    print_test "Searching for users: '$search_term'"
    if "$AT_BOT" search-users "$search_term"; then
        print_success "User search successful"
    else
        print_warning "User search failed or no results"
    fi
    
    press_enter
}

test_profile() {
    print_section "Social: Get Profile Test"
    
    if [ ! -f "$SESSION_FILE" ]; then
        print_warning "Not logged in. Please login first (option 1)."
        return
    fi
    
    read -r -p "Enter handle to view (or press Enter for own profile): " handle
    
    print_test "Fetching profile information..."
    if [ -z "$handle" ]; then
        if "$AT_BOT" profile; then
            print_success "Own profile retrieved"
        else
            print_error "Profile retrieval failed"
        fi
    else
        if "$AT_BOT" profile "$handle"; then
            print_success "Profile for $handle retrieved"
        else
            print_error "Profile retrieval failed"
        fi
    fi
    
    press_enter
}

test_followers() {
    print_section "Social: Get Followers Test"
    
    if [ ! -f "$SESSION_FILE" ]; then
        print_warning "Not logged in. Please login first (option 1)."
        return
    fi
    
    read -r -p "Enter handle (or press Enter for own followers): " handle
    
    print_test "Fetching followers..."
    if [ -z "$handle" ]; then
        if "$AT_BOT" followers; then
            print_success "Followers list retrieved"
        else
            print_error "Followers retrieval failed"
        fi
    else
        if "$AT_BOT" followers "$handle"; then
            print_success "Followers for $handle retrieved"
        else
            print_error "Followers retrieval failed"
        fi
    fi
    
    press_enter
}

test_following() {
    print_section "Social: Get Following Test"
    
    if [ ! -f "$SESSION_FILE" ]; then
        print_warning "Not logged in. Please login first (option 1)."
        return
    fi
    
    read -r -p "Enter handle (or press Enter for own following): " handle
    
    print_test "Fetching following list..."
    if [ -z "$handle" ]; then
        if "$AT_BOT" following; then
            print_success "Following list retrieved"
        else
            print_error "Following retrieval failed"
        fi
    else
        if "$AT_BOT" following "$handle"; then
            print_success "Following list for $handle retrieved"
        else
            print_error "Following retrieval failed"
        fi
    fi
    
    press_enter
}

test_follow_user() {
    print_section "Social: Follow User Test"
    
    if [ ! -f "$SESSION_FILE" ]; then
        print_warning "Not logged in. Please login first (option 1)."
        return
    fi
    
    read -r -p "Enter handle to follow: " handle
    
    if [ -z "$handle" ]; then
        print_warning "Skipped follow test"
        return
    fi
    
    print_test "Following user: $handle"
    if "$AT_BOT" follow "$handle"; then
        print_success "Successfully followed $handle"
    else
        print_warning "Follow operation failed (may already be following)"
    fi
    
    press_enter
}

test_unfollow_user() {
    print_section "Social: Unfollow User Test"
    
    if [ ! -f "$SESSION_FILE" ]; then
        print_warning "Not logged in. Please login first (option 1)."
        return
    fi
    
    read -r -p "Enter handle to unfollow: " handle
    
    if [ -z "$handle" ]; then
        print_warning "Skipped unfollow test"
        return
    fi
    
    print_test "Unfollowing user: $handle"
    if "$AT_BOT" unfollow "$handle"; then
        print_success "Successfully unfollowed $handle"
    else
        print_warning "Unfollow operation failed (may not be following)"
    fi
    
    press_enter
}

test_block_unblock() {
    print_section "Social: Block/Unblock User Test"
    
    if [ ! -f "$SESSION_FILE" ]; then
        print_warning "Not logged in. Please login first (option 1)."
        return
    fi
    
    read -r -p "Enter handle to manage: " handle
    
    if [ -z "$handle" ]; then
        print_warning "Skipped block/unblock test"
        return
    fi
    
    echo ""
    echo "1) Block user"
    echo "2) Unblock user"
    read -r -p "Choice: " choice
    
    case $choice in
        1)
            print_test "Blocking user: $handle"
            if "$AT_BOT" block "$handle"; then
                print_success "Successfully blocked $handle"
            else
                print_warning "Block operation failed"
            fi
            ;;
        2)
            print_test "Unblocking user: $handle"
            if "$AT_BOT" unblock "$handle"; then
                print_success "Successfully unblocked $handle"
            else
                print_warning "Unblock operation failed"
            fi
            ;;
        *)
            print_warning "Invalid choice"
            ;;
    esac
    
    press_enter
}

test_mute_unmute() {
    print_section "Social: Mute/Unmute User Test"
    
    if [ ! -f "$SESSION_FILE" ]; then
        print_warning "Not logged in. Please login first (option 1)."
        return
    fi
    
    read -r -p "Enter handle to manage: " handle
    
    if [ -z "$handle" ]; then
        print_warning "Skipped mute/unmute test"
        return
    fi
    
    echo ""
    echo "1) Mute user"
    echo "2) Unmute user"
    read -r -p "Choice: " choice
    
    case $choice in
        1)
            print_test "Muting user: $handle"
            if "$AT_BOT" mute "$handle"; then
                print_success "Successfully muted $handle"
            else
                print_warning "Mute operation failed"
            fi
            ;;
        2)
            print_test "Unmuting user: $handle"
            if "$AT_BOT" unmute "$handle"; then
                print_success "Successfully unmuted $handle"
            else
                print_warning "Unmute operation failed"
            fi
            ;;
        *)
            print_warning "Invalid choice"
            ;;
    esac
    
    press_enter
}

test_environment_vars() {
    print_section "Advanced: Environment Variables Test"
    
    print_test "Checking environment variables..."
    echo ""
    
    if [ -n "$BLUESKY_HANDLE" ]; then
        print_success "BLUESKY_HANDLE is set: $BLUESKY_HANDLE"
    else
        print_warning "BLUESKY_HANDLE not set"
    fi
    
    if [ -n "$DEBUG" ]; then
        print_success "DEBUG is enabled: $DEBUG"
    else
        print_warning "DEBUG not set (normal mode)"
    fi
    
    if [ -n "$ATP_PDS" ]; then
        print_success "ATP_PDS is set: $ATP_PDS"
    else
        print_warning "ATP_PDS not set (using default)"
    fi
    
    press_enter
}

test_help() {
    print_section "Advanced: Help System Test"
    
    print_test "Displaying AT-bot help..."
    echo ""
    "$AT_BOT" --help
    
    press_enter
}

test_quick_sanity() {
    print_section "Advanced: Quick Sanity Tests"
    
    print_test "Testing basic binary..."
    if "$AT_BOT" --version >/dev/null 2>&1 || "$AT_BOT" --help >/dev/null 2>&1; then
        print_success "Binary is executable"
    else
        print_error "Binary is not working"
    fi
    
    print_test "Testing library loading..."
    if "$AT_BOT" 2>&1 | grep -q "Usage\|Usage:" ; then
        print_success "Library loaded correctly"
    else
        print_warning "Library may not be loading correctly"
    fi
    
    print_test "Testing config directory..."
    if [ -d "$CONFIG_DIR" ]; then
        print_success "Config directory exists: $CONFIG_DIR"
    else
        print_warning "Config directory not created yet"
    fi
    
    if [ -f "$SESSION_FILE" ]; then
        print_success "Session file exists"
    else
        print_warning "No active session (login to create one)"
    fi
    
    press_enter
}

test_session_info() {
    print_section "Session Management: Session Info"
    
    if [ ! -f "$SESSION_FILE" ]; then
        print_warning "No active session. Please login first (option 1)."
        press_enter
        return
    fi
    
    print_test "Session file location: $SESSION_FILE"
    print_test "Session file size: $(du -h "$SESSION_FILE" | cut -f1)"
    print_test "Session file permissions: $(stat -c '%A' "$SESSION_FILE" 2>/dev/null || stat -f '%OLp' "$SESSION_FILE")"
    print_success "Session file exists and is accessible"
    
    press_enter
}

test_logout() {
    print_section "Session Management: Logout"
    
    if [ ! -f "$SESSION_FILE" ]; then
        print_warning "No active session to logout from."
        press_enter
        return
    fi
    
    read -r -p "Are you sure you want to logout? (yes/no): " confirm
    
    if [ "$confirm" != "yes" ]; then
        print_warning "Logout cancelled"
        press_enter
        return
    fi
    
    print_test "Logging out..."
    if "$AT_BOT" logout; then
        print_success "Logout successful"
    else
        print_error "Logout failed"
    fi
    
    press_enter
}

test_clear_credentials() {
    print_section "Session Management: Clear Credentials"
    
    if [ ! -f "$SESSION_FILE" ]; then
        print_warning "No credentials to clear."
        press_enter
        return
    fi
    
    read -r -p "This will permanently delete your saved credentials. Continue? (yes/no): " confirm
    
    if [ "$confirm" != "yes" ]; then
        print_warning "Clear credentials cancelled"
        press_enter
        return
    fi
    
    print_test "Clearing credentials..."
    if "$AT_BOT" clear-credentials; then
        print_success "Credentials cleared"
    else
        print_error "Failed to clear credentials"
    fi
    
    press_enter
}

# Main loop
main() {
    print_section "AT-bot Comprehensive Test Suite"
    echo -e "${CYAN}Welcome to the interactive AT-bot test suite!${NC}"
    echo ""
    echo "This suite provides comprehensive testing of all major features:"
    echo "  • Authentication and sessions"
    echo "  • Content creation and reading"
    echo "  • Social features (follow, block, mute)"
    echo "  • Search functionality"
    echo "  • Help system and environment variables"
    echo ""
    
    press_enter
    
    while true; do
        show_menu
        
        read -r -p "Enter your choice (1-21): " choice
        
        case $choice in
            1) test_login ;;
            2) test_whoami ;;
            3) test_session_validation ;;
            4) test_post ;;
            5) test_feed ;;
            6) test_search_posts ;;
            7) test_search_users ;;
            8) test_profile ;;
            9) test_followers ;;
            10) test_following ;;
            11) test_follow_user ;;
            12) test_unfollow_user ;;
            13) test_block_unblock ;;
            14) test_mute_unmute ;;
            15) test_environment_vars ;;
            16) test_help ;;
            17) test_quick_sanity ;;
            18) test_session_info ;;
            19) test_logout ;;
            20) test_clear_credentials ;;
            21)
                print_section "Test Suite Summary"
                echo -e "${GREEN}Tests passed: $TESTS_PASSED${NC}"
                echo -e "${YELLOW}Tests skipped: $TESTS_SKIPPED${NC}"
                echo -e "${RED}Tests failed: $TESTS_FAILED${NC}"
                echo ""
                echo "Thank you for testing AT-bot!"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice. Please enter a number between 1 and 21.${NC}"
                ;;
        esac
    done
}

# Run main
main "$@"
