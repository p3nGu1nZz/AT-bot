#!/bin/bash
# Comprehensive manual testing helper for atproto
# This script provides interactive testing of all major atproto features
# with multi-level menu navigation and authentication onboarding

# Don't use set -e as it interferes with interactive menu and read commands
# Instead, use proper error handling in critical sections

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
AT_BOT="$PROJECT_ROOT/bin/atproto"
CONFIG_DIR="$HOME/.config/atproto"
SESSION_FILE="$CONFIG_DIR/session.json"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
DIM='\033[2m'
NC='\033[0m'

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# Current user
CURRENT_USER=""

# ═══════════════════════════════════════════════════════════════
# Helper Functions
# ═══════════════════════════════════════════════════════════════

clear_screen() {
    clear
}

print_header() {
    clear_screen
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  ${WHITE}atproto Comprehensive Test Suite${NC}                          ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}"
}

print_section() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
    printf "${CYAN}║${NC}  %-56s${CYAN}║${NC}\n" "$1"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}"
}

print_test() {
    echo -e "${BLUE}  ▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}  ✓ $1${NC}"
    ((TESTS_PASSED++))
}

print_error() {
    echo -e "${RED}  ✗ $1${NC}"
    ((TESTS_FAILED++))
}

print_warning() {
    echo -e "${YELLOW}  ⚠ $1${NC}"
    ((TESTS_SKIPPED++))
}

print_info() {
    echo -e "${BLUE}  ℹ $1${NC}"
}

press_enter() {
    echo ""
    read -r -p "Press Enter to continue..."
}

# ═══════════════════════════════════════════════════════════════
# Authentication & Onboarding
# ═══════════════════════════════════════════════════════════════

check_authentication() {
    if [ -f "$SESSION_FILE" ]; then
        if output=$("$AT_BOT" whoami 2>&1); then
            CURRENT_USER=$(echo "$output" | grep "Handle:" | grep -oP '(?<=Handle: ).*' || echo "User")
            return 0
        fi
    fi
    return 1
}

show_auth_onboarding() {
    print_header
    echo ""
    echo -e "${YELLOW}  👋 Welcome to atproto Test Suite!${NC}"
    echo ""
    echo -e "${WHITE}  No active session detected${NC}"
    echo -e "${DIM}  Let's get you authenticated first.${NC}"
    echo ""
    press_enter
    
    print_header
    print_section "🔐 Authentication Setup"
    echo ""
    echo -e "${WHITE}  We'll securely store your credentials${NC}"
    echo -e "${DIM}  for this testing session.${NC}"
    echo ""
    echo -e "${DIM}  Tips:${NC}"
    echo -e "${DIM}    • Use app passwords for security${NC}"
    echo -e "${DIM}    • Never share your credentials${NC}"
    echo -e "${DIM}    • Credentials are stored locally${NC}"
    echo ""
    echo -e "${CYAN}───────────────────────────────────────────────────────────${NC}"
    echo ""
    
    if "$AT_BOT" login; then
        echo ""
        echo -e "${GREEN}✓ Authentication successful!${NC}"
        
        if output=$("$AT_BOT" whoami 2>&1); then
            CURRENT_USER=$(echo "$output" | grep "Handle:" | grep -oP '(?<=Handle: ).*' || echo "User")
            print_success "Logged in as: $CURRENT_USER"
        fi
        
        press_enter
        return 0
    else
        print_error "Authentication failed. Please try again."
        press_enter
        return 1
    fi
}

ensure_authenticated() {
    while ! check_authentication; do
        if ! show_auth_onboarding; then
            echo ""
            read -r -p "Try again? (yes/no): " retry
            if [ "$retry" != "yes" ]; then
                echo -e "${YELLOW}Exiting test suite.${NC}"
                exit 0
            fi
        fi
    done
}

# ═══════════════════════════════════════════════════════════════
# Menu Navigation
# ═══════════════════════════════════════════════════════════════

show_main_menu() {
    print_header
    echo ""
    echo -e "${WHITE}  Logged in as: ${CYAN}$CURRENT_USER${NC}"
    echo ""
    echo -e "${WHITE}  Select a test category:${NC}"
    echo ""
    echo -e "${CYAN}  ┌─ Test Categories ────────────────────────────┐${NC}"
    echo -e "${CYAN}  │${NC}  [1] 🔐  Authentication & Session             ${CYAN}│${NC}"
    echo -e "${CYAN}  │${NC}  [2] 📝  Content Management                  ${CYAN}│${NC}"
    echo -e "${CYAN}  │${NC}  [3] 👥  Social Interactions                 ${CYAN}│${NC}"
    echo -e "${CYAN}  │${NC}  [4] 🔍  Search & Discovery                  ${CYAN}│${NC}"
    echo -e "${CYAN}  │${NC}  [5] 📊  User Profiles                       ${CYAN}│${NC}"
    echo -e "${CYAN}  │${NC}  [6] ⚙️   System & Configuration             ${CYAN}│${NC}"
    echo -e "${CYAN}  │${NC}  [7] 🧪  Diagnostics                        ${CYAN}│${NC}"
    echo -e "${CYAN}  │${NC}  [0] 🚪  Exit                               ${CYAN}│${NC}"
    echo -e "${CYAN}  └──────────────────────────────────────────────┘${NC}"
    echo ""
}

show_auth_menu() {
    print_header
    echo ""
    echo -e "${WHITE}  Category: 🔐 Authentication & Session${NC}"
    echo ""
    echo -e "${CYAN}  ┌─ Tests ──────────────────────────────────────┐${NC}"
    echo -e "${CYAN}  │${NC}  [1] Verify Current User (whoami)         ${CYAN}│${NC}"
    echo -e "${CYAN}  │${NC}  [2] Validate Session                    ${CYAN}│${NC}"
    echo -e "${CYAN}  │${NC}  [3] View Session Info                   ${CYAN}│${NC}"
    echo -e "${CYAN}  │${NC}  [4] Logout                              ${CYAN}│${NC}"
    echo -e "${CYAN}  │${NC}  [5] Clear Credentials                   ${CYAN}│${NC}"
    echo -e "${CYAN}  │${NC}  [0] 🔙 Back                             ${CYAN}│${NC}"
    echo -e "${CYAN}  └──────────────────────────────────────────────┘${NC}"
    echo ""
}

show_content_menu() {
    print_header
    echo ""
    echo -e "${WHITE}  Category: 📝 Content Management${NC}"
    echo ""
    echo -e "${CYAN}  ┌─ Tests ──────────────────────────────────────┐${NC}"
    echo -e "${CYAN}  │${NC}  [1] Create a Post                         ${CYAN}│${NC}"
    echo -e "${CYAN}  │${NC}  [2] Read Your Feed                       ${CYAN}│${NC}"
    echo -e "${CYAN}  │${NC}  [0] 🔙 Back                             ${CYAN}│${NC}"
    echo -e "${CYAN}  └──────────────────────────────────────────────┘${NC}"
    echo ""
}

show_social_menu() {
    print_header
    echo ""
    echo -e "${WHITE}  Category: 👥 Social Interactions${NC}"
    echo ""
    echo -e "${CYAN}  ┌─ Tests ──────────────────────────────────────┐${NC}"
    echo -e "${CYAN}  │${NC}  [1] Follow a User                         ${CYAN}│${NC}"
    echo -e "${CYAN}  │${NC}  [2] Unfollow a User                      ${CYAN}│${NC}"
    echo -e "${CYAN}  │${NC}  [3] Block a User                         ${CYAN}│${NC}"
    echo -e "${CYAN}  │${NC}  [4] Unblock a User                       ${CYAN}│${NC}"
    echo -e "${CYAN}  │${NC}  [5] Mute a User                          ${CYAN}│${NC}"
    echo -e "${CYAN}  │${NC}  [6] Unmute a User                        ${CYAN}│${NC}"
    echo -e "${CYAN}  │${NC}  [0] 🔙 Back                             ${CYAN}│${NC}"
    echo -e "${CYAN}  └──────────────────────────────────────────────┘${NC}"
    echo ""
}

show_search_menu() {
    print_header
    echo ""
    echo -e "${WHITE}  Category: 🔍 Search & Discovery${NC}"
    echo ""
    echo -e "${CYAN}  ┌─ Tests ──────────────────────────────────────┐${NC}"
    echo -e "${CYAN}  │${NC}  [1] Search Posts                          ${CYAN}│${NC}"
    echo -e "${CYAN}  │${NC}  [2] Search Users                         ${CYAN}│${NC}"
    echo -e "${CYAN}  │${NC}  [0] 🔙 Back                             ${CYAN}│${NC}"
    echo -e "${CYAN}  └──────────────────────────────────────────────┘${NC}"
    echo ""
}

show_profile_menu() {
    print_header
    echo ""
    echo -e "${WHITE}  Category: 📊 User Profiles${NC}"
    echo ""
    echo -e "${CYAN}  ┌─ Tests ──────────────────────────────────────┐${NC}"
    echo -e "${CYAN}  │${NC}  [1] View Your Profile                     ${CYAN}│${NC}"
    echo -e "${CYAN}  │${NC}  [2] View Another Profile                 ${CYAN}│${NC}"
    echo -e "${CYAN}  │${NC}  [3] View Your Followers                  ${CYAN}│${NC}"
    echo -e "${CYAN}  │${NC}  [4] View User Followers                  ${CYAN}│${NC}"
    echo -e "${CYAN}  │${NC}  [5] View Who You Follow                  ${CYAN}│${NC}"
    echo -e "${CYAN}  │${NC}  [6] View Who Follows User                ${CYAN}│${NC}"
    echo -e "${CYAN}  │${NC}  [0] 🔙 Back                             ${CYAN}│${NC}"
    echo -e "${CYAN}  └──────────────────────────────────────────────┘${NC}"
    echo ""
}

show_system_menu() {
    print_header
    echo ""
    echo -e "${WHITE}  Category: ⚙️   System & Configuration${NC}"
    echo ""
    echo -e "${CYAN}  ┌─ Tests ──────────────────────────────────────┐${NC}"
    echo -e "${CYAN}  │${NC}  [1] View Help                             ${CYAN}│${NC}"
    echo -e "${CYAN}  │${NC}  [2] Check Environment Variables          ${CYAN}│${NC}"
    echo -e "${CYAN}  │${NC}  [3] View Configuration Directory          ${CYAN}│${NC}"
    echo -e "${CYAN}  │${NC}  [0] 🔙 Back                             ${CYAN}│${NC}"
    echo -e "${CYAN}  └──────────────────────────────────────────────┘${NC}"
    echo ""
}

show_diagnostics_menu() {
    print_header
    echo ""
    echo -e "${WHITE}  Category: 🧪 Diagnostics${NC}"
    echo ""
    echo -e "${CYAN}  ┌─ Tests ──────────────────────────────────────┐${NC}"
    echo -e "${CYAN}  │${NC}  [1] Quick Sanity Check                    ${CYAN}│${NC}"
    echo -e "${CYAN}  │${NC}  [2] Verify Binary                        ${CYAN}│${NC}"
    echo -e "${CYAN}  │${NC}  [3] Check Dependencies                   ${CYAN}│${NC}"
    echo -e "${CYAN}  │${NC}  [4] Test Report                          ${CYAN}│${NC}"
    echo -e "${CYAN}  │${NC}  [0] 🔙 Back                             ${CYAN}│${NC}"
    echo -e "${CYAN}  └──────────────────────────────────────────────┘${NC}"
    echo ""
}

# ═══════════════════════════════════════════════════════════════
# Test Functions - Authentication
# ═══════════════════════════════════════════════════════════════

test_whoami() {
    print_section "🔐 Verify Current User"
    echo ""
    print_test "Checking current user..."
    if output=$("$AT_BOT" whoami); then
        print_success "User information retrieved:"
        echo ""
        echo "$output" | sed 's/^/  /'
    else
        print_error "Failed to retrieve user information"
    fi
    press_enter
}

test_validate_session() {
    print_section "🔐 Validate Session"
    echo ""
    print_test "Validating session by retrieving user info..."
    if output=$("$AT_BOT" whoami 2>&1); then
        print_success "Session is valid! User info:"
        echo ""
        echo "$output" | sed 's/^/  /'
    else
        print_error "Session validation failed - session may be expired"
    fi
    press_enter
}

test_session_info() {
    print_section "🔐 Session Information"
    echo ""
    if [ ! -f "$SESSION_FILE" ]; then
        print_warning "No session file found"
        press_enter
        return
    fi
    
    print_test "Session file location: $SESSION_FILE"
    print_test "Session file size: $(du -h "$SESSION_FILE" | cut -f1)"
    
    if command -v stat >/dev/null 2>&1; then
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            perms=$(stat -c '%A' "$SESSION_FILE")
        else
            perms=$(stat -f '%OLp' "$SESSION_FILE")
        fi
        print_test "Session file permissions: $perms"
    fi
    
    print_success "Session file exists and is accessible"
    press_enter
}

test_logout() {
    print_section "🔐 Logout"
    echo ""
    read -r -p "  Are you sure you want to logout? (yes/no): " confirm
    
    if [ "$confirm" != "yes" ]; then
        print_warning "Logout cancelled"
        press_enter
        return
    fi
    
    echo ""
    print_test "Logging out..."
    if "$AT_BOT" logout; then
        print_success "Logout successful"
        CURRENT_USER=""
    else
        print_error "Logout failed"
    fi
    press_enter
}

test_clear_credentials() {
    print_section "🔐 Clear Credentials"
    echo ""
    echo -e "${YELLOW}  ⚠️  WARNING: This will permanently delete your saved credentials${NC}"
    read -r -p "  Continue? (yes/no): " confirm
    
    if [ "$confirm" != "yes" ]; then
        print_warning "Clear credentials cancelled"
        press_enter
        return
    fi
    
    echo ""
    print_test "Clearing credentials..."
    if "$AT_BOT" clear-credentials; then
        print_success "Credentials cleared"
        CURRENT_USER=""
    else
        print_error "Failed to clear credentials"
    fi
    press_enter
}

# ═══════════════════════════════════════════════════════════════
# Test Functions - Content
# ═══════════════════════════════════════════════════════════════

test_create_post() {
    print_section "�� Create a Post"
    echo ""
    read -r -p "  Enter post text (or press Enter to skip): " post_text
    
    if [ -z "$post_text" ]; then
        print_warning "Post creation skipped"
        press_enter
        return
    fi
    
    echo ""
    print_test "Creating post: '$post_text'"
    if "$AT_BOT" post "$post_text"; then
        print_success "Post created successfully"
    else
        print_error "Post creation failed"
    fi
    press_enter
}

test_read_feed() {
    print_section "📝 Read Your Feed"
    echo ""
    read -r -p "  How many posts to fetch? (default 5): " limit
    limit=${limit:-5}
    
    echo ""
    print_test "Fetching $limit posts from your feed..."
    if "$AT_BOT" feed "$limit"; then
        print_success "Feed retrieval successful"
    else
        print_error "Feed retrieval failed"
    fi
    press_enter
}

# ═══════════════════════════════════════════════════════════════
# Test Functions - Social
# ═══════════════════════════════════════════════════════════════

test_follow_user() {
    print_section "👥 Follow a User"
    echo ""
    read -r -p "  Enter handle to follow: " handle
    
    if [ -z "$handle" ]; then
        print_warning "Follow operation skipped"
        press_enter
        return
    fi
    
    echo ""
    print_test "Following user: $handle"
    if "$AT_BOT" follow "$handle"; then
        print_success "Successfully followed $handle"
    else
        print_warning "Follow operation failed (may already be following)"
    fi
    press_enter
}

test_unfollow_user() {
    print_section "👥 Unfollow a User"
    echo ""
    read -r -p "  Enter handle to unfollow: " handle
    
    if [ -z "$handle" ]; then
        print_warning "Unfollow operation skipped"
        press_enter
        return
    fi
    
    echo ""
    print_test "Unfollowing user: $handle"
    if "$AT_BOT" unfollow "$handle"; then
        print_success "Successfully unfollowed $handle"
    else
        print_warning "Unfollow operation failed (may not be following)"
    fi
    press_enter
}

test_block_user() {
    print_section "👥 Block a User"
    echo ""
    read -r -p "  Enter handle to block: " handle
    
    if [ -z "$handle" ]; then
        print_warning "Block operation skipped"
        press_enter
        return
    fi
    
    echo ""
    print_test "Blocking user: $handle"
    if "$AT_BOT" block "$handle"; then
        print_success "Successfully blocked $handle"
    else
        print_warning "Block operation failed"
    fi
    press_enter
}

test_unblock_user() {
    print_section "👥 Unblock a User"
    echo ""
    read -r -p "  Enter handle to unblock: " handle
    
    if [ -z "$handle" ]; then
        print_warning "Unblock operation skipped"
        press_enter
        return
    fi
    
    echo ""
    print_test "Unblocking user: $handle"
    if "$AT_BOT" unblock "$handle"; then
        print_success "Successfully unblocked $handle"
    else
        print_warning "Unblock operation failed"
    fi
    press_enter
}

test_mute_user() {
    print_section "👥 Mute a User"
    echo ""
    read -r -p "  Enter handle to mute: " handle
    
    if [ -z "$handle" ]; then
        print_warning "Mute operation skipped"
        press_enter
        return
    fi
    
    echo ""
    print_test "Muting user: $handle"
    if "$AT_BOT" mute "$handle"; then
        print_success "Successfully muted $handle"
    else
        print_warning "Mute operation failed"
    fi
    press_enter
}

test_unmute_user() {
    print_section "👥 Unmute a User"
    echo ""
    read -r -p "  Enter handle to unmute: " handle
    
    if [ -z "$handle" ]; then
        print_warning "Unmute operation skipped"
        press_enter
        return
    fi
    
    echo ""
    print_test "Unmuting user: $handle"
    if "$AT_BOT" unmute "$handle"; then
        print_success "Successfully unmuted $handle"
    else
        print_warning "Unmute operation failed"
    fi
    press_enter
}

# ═══════════════════════════════════════════════════════════════
# Test Functions - Search
# ═══════════════════════════════════════════════════════════════

test_search_posts() {
    print_section "🔍 Search Posts"
    echo ""
    read -r -p "  Enter search term for posts: " search_term
    
    if [ -z "$search_term" ]; then
        print_warning "Post search skipped"
        press_enter
        return
    fi
    
    echo ""
    print_test "Searching for posts: '$search_term'"
    if "$AT_BOT" search-posts "$search_term"; then
        print_success "Post search successful"
    else
        print_warning "Post search failed or no results"
    fi
    press_enter
}

test_search_users() {
    print_section "🔍 Search Users"
    echo ""
    read -r -p "  Enter search term for users: " search_term
    
    if [ -z "$search_term" ]; then
        print_warning "User search skipped"
        press_enter
        return
    fi
    
    echo ""
    print_test "Searching for users: '$search_term'"
    if "$AT_BOT" search-users "$search_term"; then
        print_success "User search successful"
    else
        print_warning "User search failed or no results"
    fi
    press_enter
}

# ═══════════════════════════════════════════════════════════════
# Test Functions - Profiles
# ═══════════════════════════════════════════════════════════════

test_view_own_profile() {
    print_section "�� View Your Profile"
    echo ""
    print_test "Fetching your profile..."
    if "$AT_BOT" profile; then
        print_success "Profile retrieved successfully"
    else
        print_error "Profile retrieval failed"
    fi
    press_enter
}

test_view_other_profile() {
    print_section "📊 View Another Profile"
    echo ""
    read -r -p "  Enter handle to view: " handle
    
    if [ -z "$handle" ]; then
        print_warning "Profile view skipped"
        press_enter
        return
    fi
    
    echo ""
    print_test "Fetching profile for $handle..."
    if "$AT_BOT" profile "$handle"; then
        print_success "Profile retrieved successfully"
    else
        print_error "Profile retrieval failed"
    fi
    press_enter
}

test_view_own_followers() {
    print_section "📊 View Your Followers"
    echo ""
    print_test "Fetching your followers..."
    if "$AT_BOT" followers; then
        print_success "Followers list retrieved"
    else
        print_error "Followers retrieval failed"
    fi
    press_enter
}

test_view_user_followers() {
    print_section "📊 View User Followers"
    echo ""
    read -r -p "  Enter handle to view followers for: " handle
    
    if [ -z "$handle" ]; then
        print_warning "Followers view skipped"
        press_enter
        return
    fi
    
    echo ""
    print_test "Fetching followers for $handle..."
    if "$AT_BOT" followers "$handle"; then
        print_success "Followers list retrieved"
    else
        print_error "Followers retrieval failed"
    fi
    press_enter
}

test_view_own_following() {
    print_section "📊 View Who You Follow"
    echo ""
    print_test "Fetching who you follow..."
    if "$AT_BOT" following; then
        print_success "Following list retrieved"
    else
        print_error "Following retrieval failed"
    fi
    press_enter
}

test_view_user_following() {
    print_section "📊 View Who Follows User"
    echo ""
    read -r -p "  Enter handle to view following for: " handle
    
    if [ -z "$handle" ]; then
        print_warning "Following view skipped"
        press_enter
        return
    fi
    
    echo ""
    print_test "Fetching following for $handle..."
    if "$AT_BOT" following "$handle"; then
        print_success "Following list retrieved"
    else
        print_error "Following retrieval failed"
    fi
    press_enter
}

# ═══════════════════════════════════════════════════════════════
# Test Functions - System
# ═══════════════════════════════════════════════════════════════

test_view_help() {
    print_section "⚙️   View Help"
    echo ""
    "$AT_BOT" --help || true
    press_enter
}

test_environment_vars() {
    print_section "⚙️   Environment Variables"
    echo ""
    
    if [ -n "$BLUESKY_HANDLE" ]; then
        print_success "BLUESKY_HANDLE: $BLUESKY_HANDLE"
    else
        print_info "BLUESKY_HANDLE not set"
    fi
    
    if [ -n "$DEBUG" ]; then
        print_success "DEBUG: $DEBUG (enabled)"
    else
        print_info "DEBUG not set (normal mode)"
    fi
    
    if [ -n "$ATP_PDS" ]; then
        print_success "ATP_PDS: $ATP_PDS"
    else
        print_info "ATP_PDS not set (using default: https://bsky.social)"
    fi
    
    press_enter
}

test_config_directory() {
    print_section "⚙️   Configuration Directory"
    echo ""
    print_info "Config directory: $CONFIG_DIR"
    
    if [ -d "$CONFIG_DIR" ]; then
        print_success "Config directory exists"
        echo ""
        print_info "Contents:"
        ls -lh "$CONFIG_DIR" 2>/dev/null | tail -n +2 | sed 's/^/  /' || print_warning "Unable to list contents"
    else
        print_warning "Config directory not created yet"
    fi
    
    press_enter
}

# ═══════════════════════════════════════════════════════════════
# Test Functions - Diagnostics
# ═══════════════════════════════════════════════════════════════

test_sanity_check() {
    print_section "�� Quick Sanity Check"
    echo ""
    
    print_test "Testing binary..."
    if "$AT_BOT" --help >/dev/null 2>&1; then
        print_success "Binary is executable"
    else
        print_error "Binary is not working"
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
        print_warning "No active session"
    fi
    
    print_test "Testing library..."
    if "$AT_BOT" 2>&1 | grep -q "Usage" ; then
        print_success "Library loaded correctly"
    else
        print_warning "Library check inconclusive"
    fi
    
    press_enter
}

test_verify_binary() {
    print_section "🧪 Verify Binary"
    echo ""
    
    which_out=$(which atproto 2>/dev/null || echo "Not in PATH")
    print_info "Binary location: $which_out"
    
    if [ -x "$AT_BOT" ]; then
        print_success "Binary is executable"
        ls -lh "$AT_BOT" | sed 's/^/  /'
    else
        print_error "Binary is not executable"
    fi
    
    press_enter
}

test_check_dependencies() {
    print_section "🧪 Check Dependencies"
    echo ""
    
    local deps=("bash" "curl" "grep" "sed" "awk" "openssl")
    
    for dep in "${deps[@]}"; do
        if command -v "$dep" >/dev/null 2>&1; then
            print_success "$dep found"
        else
            print_error "$dep not found"
        fi
    done
    
    press_enter
}

test_report() {
    print_section "🧪 Test Report"
    echo ""
    echo -e "${WHITE}  Test Summary:${NC}"
    echo ""
    echo -e "  ${GREEN}Passed:  $TESTS_PASSED${NC}"
    echo -e "  ${YELLOW}Skipped: $TESTS_SKIPPED${NC}"
    echo -e "  ${RED}Failed:  $TESTS_FAILED${NC}"
    echo ""
    echo -e "${DIM}  Total tests run: $((TESTS_PASSED + TESTS_FAILED + TESTS_SKIPPED))${NC}"
    
    press_enter
}

# ═══════════════════════════════════════════════════════════════
# Navigation Handlers
# ═══════════════════════════════════════════════════════════════

handle_auth_menu() {
    while true; do
        show_auth_menu
        read -r -p "Enter your choice (0-5): " choice
        
        case $choice in
            1) test_whoami ;;
            2) test_validate_session ;;
            3) test_session_info ;;
            4) test_logout ;;
            5) test_clear_credentials ;;
            0) return ;;
            *) echo -e "${RED}Invalid choice${NC}"; sleep 1 ;;
        esac
    done
}

handle_content_menu() {
    while true; do
        show_content_menu
        read -r -p "Enter your choice (0-2): " choice
        
        case $choice in
            1) test_create_post ;;
            2) test_read_feed ;;
            0) return ;;
            *) echo -e "${RED}Invalid choice${NC}"; sleep 1 ;;
        esac
    done
}

handle_social_menu() {
    while true; do
        show_social_menu
        read -r -p "Enter your choice (0-6): " choice
        
        case $choice in
            1) test_follow_user ;;
            2) test_unfollow_user ;;
            3) test_block_user ;;
            4) test_unblock_user ;;
            5) test_mute_user ;;
            6) test_unmute_user ;;
            0) return ;;
            *) echo -e "${RED}Invalid choice${NC}"; sleep 1 ;;
        esac
    done
}

handle_search_menu() {
    while true; do
        show_search_menu
        read -r -p "Enter your choice (0-2): " choice
        
        case $choice in
            1) test_search_posts ;;
            2) test_search_users ;;
            0) return ;;
            *) echo -e "${RED}Invalid choice${NC}"; sleep 1 ;;
        esac
    done
}

handle_profile_menu() {
    while true; do
        show_profile_menu
        read -r -p "Enter your choice (0-6): " choice
        
        case $choice in
            1) test_view_own_profile ;;
            2) test_view_other_profile ;;
            3) test_view_own_followers ;;
            4) test_view_user_followers ;;
            5) test_view_own_following ;;
            6) test_view_user_following ;;
            0) return ;;
            *) echo -e "${RED}Invalid choice${NC}"; sleep 1 ;;
        esac
    done
}

handle_system_menu() {
    while true; do
        show_system_menu
        read -r -p "Enter your choice (0-3): " choice
        
        case $choice in
            1) test_view_help ;;
            2) test_environment_vars ;;
            3) test_config_directory ;;
            0) return ;;
            *) echo -e "${RED}Invalid choice${NC}"; sleep 1 ;;
        esac
    done
}

handle_diagnostics_menu() {
    while true; do
        show_diagnostics_menu
        read -r -p "Enter your choice (0-4): " choice
        
        case $choice in
            1) test_sanity_check ;;
            2) test_verify_binary ;;
            3) test_check_dependencies ;;
            4) test_report ;;
            0) return ;;
            *) echo -e "${RED}Invalid choice${NC}"; sleep 1 ;;
        esac
    done
}

# ═══════════════════════════════════════════════════════════════
# Main Loop
# ═══════════════════════════════════════════════════════════════

main() {
    # Ensure authenticated before proceeding
    ensure_authenticated
    
    # Main menu loop
    while true; do
        show_main_menu
        read -r -p "Enter your choice (0-7): " choice
        
        case $choice in
            1) handle_auth_menu ;;
            2) handle_content_menu ;;
            3) handle_social_menu ;;
            4) handle_search_menu ;;
            5) handle_profile_menu ;;
            6) handle_system_menu ;;
            7) handle_diagnostics_menu ;;
            0)
                print_header
                echo ""
                echo -e "${YELLOW}  Thank you for testing atproto!${NC}"
                echo ""
                echo -e "${CYAN}  Test Summary:${NC}"
                echo -e "    ${GREEN}Passed:  $TESTS_PASSED${NC}"
                echo -e "    ${YELLOW}Skipped: $TESTS_SKIPPED${NC}"
                echo -e "    ${RED}Failed:  $TESTS_FAILED${NC}"
                echo ""
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice${NC}"
                sleep 1
                ;;
        esac
    done
}

# Run main
main "$@"
