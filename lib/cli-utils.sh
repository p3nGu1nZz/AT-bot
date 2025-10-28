#!/bin/bash
# AT-bot enhanced CLI enhancements
# This file provides error code standardization and better error messages

# Standard error codes
readonly ERR_NOT_AUTHENTICATED=101
readonly ERR_INVALID_INPUT=102
readonly ERR_NETWORK_ERROR=103
readonly ERR_NOT_FOUND=104
readonly ERR_PERMISSION_DENIED=105
readonly ERR_RATE_LIMITED=106
readonly ERR_SERVER_ERROR=107
readonly ERR_SESSION_EXPIRED=108
readonly ERR_INVALID_CREDENTIALS=109

# Improved error handling with helpful suggestions
error_with_suggestion() {
    local code="$1"
    local message="$2"
    local suggestion="$3"
    
    error "$message"
    [ -n "$suggestion" ] && echo "💡 Suggestion: $suggestion" >&2
    return "$code"
}

# Handle specific error scenarios
handle_auth_error() {
    error "Authentication failed"
    error_with_suggestion "$ERR_NOT_AUTHENTICATED" \
        "Not logged in" \
        "Run 'at-bot login' to authenticate"
}

handle_invalid_input() {
    local input="$1"
    error "Invalid input: $input"
    error_with_suggestion "$ERR_INVALID_INPUT" \
        "Input validation failed" \
        "Check the input format and try again"
}

handle_network_error() {
    local endpoint="$1"
    error "Network error connecting to: $endpoint"
    error_with_suggestion "$ERR_NETWORK_ERROR" \
        "Cannot reach AT Protocol server" \
        "Check your internet connection or try a different PDS endpoint"
}

handle_rate_limit() {
    error "Rate limited by AT Protocol server"
    error_with_suggestion "$ERR_RATE_LIMITED" \
        "Too many requests" \
        "Wait a moment and try again later"
}

# Validate common inputs
validate_handle() {
    local handle="$1"
    
    if [ -z "$handle" ]; then
        error_with_suggestion "$ERR_INVALID_INPUT" \
            "Handle is required" \
            "Provide a Bluesky handle (e.g., alice.bsky.social)"
        return 1
    fi
    
    # Basic format check: should contain .bsky.social or @
    if ! echo "$handle" | grep -qE '(@|\.bsky\.social|^did:plc:)'; then
        error_with_suggestion "$ERR_INVALID_INPUT" \
            "Invalid handle format: $handle" \
            "Use format: handle.bsky.social or @handle"
        return 1
    fi
    
    return 0
}

validate_uri() {
    local uri="$1"
    
    if [ -z "$uri" ]; then
        error_with_suggestion "$ERR_INVALID_INPUT" \
            "Post URI is required" \
            "Use format: at://did:plc:.../app.bsky.feed.post/..."
        return 1
    fi
    
    if ! echo "$uri" | grep -qE '^at://did:plc:'; then
        error_with_suggestion "$ERR_INVALID_INPUT" \
            "Invalid post URI format: $uri" \
            "Post URIs should start with at://did:plc:"
        return 1
    fi
    
    return 0
}

validate_post_text() {
    local text="$1"
    
    if [ -z "$text" ]; then
        error_with_suggestion "$ERR_INVALID_INPUT" \
            "Post text is required" \
            "Provide text content for the post"
        return 1
    fi
    
    # Check length (300 character limit)
    if [ ${#text} -gt 300 ]; then
        error_with_suggestion "$ERR_INVALID_INPUT" \
            "Post text too long: ${#text} characters (max 300)" \
            "Shorten your post and try again"
        return 1
    fi
    
    return 0
}

validate_file_exists() {
    local file="$1"
    
    if [ ! -f "$file" ]; then
        error_with_suggestion "$ERR_NOT_FOUND" \
            "File not found: $file" \
            "Check the file path and try again"
        return 1
    fi
    
    return 0
}

# Format output messages consistently
output_success() {
    local message="$1"
    success "✓ $message"
}

output_info() {
    local message="$1"
    echo "ℹ $message"
}

output_warning() {
    local message="$1"
    warning "⚠ $message"
}

# Get helpful messages for common issues
get_help_for_command() {
    local cmd="$1"
    
    case "$cmd" in
        login)
            cat << 'EOF'
Usage: at-bot login [options]
Login to your Bluesky account

Options:
  --handle <handle>    Your Bluesky handle
  --password <pwd>     Your app password

Environment variables:
  BLUESKY_HANDLE       Set your handle
  BLUESKY_PASSWORD     Set your password (use with care!)

Examples:
  at-bot login                    # Interactive login
  at-bot login --handle user.bsky.social --password xxxx-xxxx-xxxx-xxxx

Note: Use app passwords, not your main account password!
      Generate at: https://bsky.app/settings/app-passwords
EOF
            ;;
        post)
            cat << 'EOF'
Usage: at-bot post [options] <text>
Create a new post on Bluesky

Options:
  --image <file>       Attach an image to the post

Examples:
  at-bot post "Hello Bluesky!"
  at-bot post --image photo.jpg "Check this out!"

Tips:
  - Posts are limited to 300 characters
  - Images must be PNG or JPEG format
  - You can attach up to 4 images per post
EOF
            ;;
        follow)
            cat << 'EOF'
Usage: at-bot follow <handle>
Follow a user on Bluesky

Examples:
  at-bot follow alice.bsky.social
  at-bot follow @alice

Tips:
  - Use the full handle (handle.bsky.social)
  - You can also use @handle shorthand
EOF
            ;;
        search)
            cat << 'EOF'
Usage: at-bot search [options] <query>
Search for posts on Bluesky

Options:
  --limit <n>          Maximum number of results (default: 10)

Examples:
  at-bot search "bluesky"
  at-bot search "bluesky" --limit 50
  at-bot search "#atprotocol" 20
  at-bot search "@alice"

Tips:
  - Use hashtags: #atprotocol
  - Mention users: @alice
  - Regular text search
EOF
            ;;
        *)
            echo "No specific help available for: $cmd"
            echo "Run 'at-bot help' for general help"
            return 1
            ;;
    esac
}

# Utility function to list all commands
list_commands() {
    cat << 'EOF'
Available commands:

  Authentication:
    login               - Authenticate with Bluesky
    logout              - Clear session and sign out
    refresh             - Refresh session token
    whoami              - Show current user

  Posts:
    post <text>         - Create a new post
    reply <uri> <text>  - Reply to a post
    like <uri>          - Like a post
    repost <uri>        - Repost a post

  Discovery:
    feed [limit]        - Read your timeline
    search <query>      - Search for posts
    profile [handle]    - View profile

  Social:
    follow <handle>     - Follow a user
    unfollow <handle>   - Unfollow a user
    followers [handle]  - View followers list
    following [handle]  - View following list

  Configuration:
    config list         - Show configuration
    config get <key>    - Get a value
    config set <key> <val> - Set a value

  Other:
    help                - Show help (or: help <command>)
    version             - Show version

Use: at-bot help <command> for detailed help on a command
EOF
}
