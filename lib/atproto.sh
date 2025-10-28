#!/bin/bash
# AT Protocol Library Functions
# Provides core functionality for interacting with Bluesky's AT Protocol

# Configuration
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/at-bot"
SESSION_FILE="$CONFIG_DIR/session.json"
ATP_PDS="${ATP_PDS:-https://bsky.social}"

# Color output support
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    NC='\033[0m' # No Color
else
    RED=''
    GREEN=''
    YELLOW=''
    NC=''
fi

# Print error message
error() {
    echo -e "${RED}Error:${NC} $*" >&2
}

# Print success message
success() {
    echo -e "${GREEN}$*${NC}"
}

# Print warning message
warning() {
    echo -e "${YELLOW}Warning:${NC} $*" >&2
}

# Read user input securely
read_secure() {
    local prompt="$1"
    local var_name="$2"
    local value
    
    if [ -t 0 ]; then
        read -r -p "$prompt" value
    else
        error "Cannot read from non-interactive terminal"
        return 1
    fi
    
    eval "$var_name='$value'"
}

# Read password securely
read_password() {
    local prompt="$1"
    local var_name="$2"
    local value
    
    if [ -t 0 ]; then
        read -r -s -p "$prompt" value
        echo >&2
    else
        error "Cannot read password from non-interactive terminal"
        return 1
    fi
    
    eval "$var_name='$value'"
}

# Make API request
api_request() {
    local method="$1"
    local endpoint="$2"
    local data="$3"
    local auth_header="${4:-}"
    
    local url="${ATP_PDS}${endpoint}"
    local curl_opts=(-s -X "$method")
    
    if [ -n "$data" ]; then
        curl_opts+=(-H "Content-Type: application/json" -d "$data")
    fi
    
    if [ -n "$auth_header" ]; then
        curl_opts+=(-H "Authorization: Bearer $auth_header")
    fi
    
    curl "${curl_opts[@]}" "$url"
}

# Login to Bluesky
atproto_login() {
    local identifier="${BLUESKY_HANDLE:-}"
    local password="${BLUESKY_PASSWORD:-}"
    
    # Check if already logged in
    if [ -f "$SESSION_FILE" ]; then
        warning "Already logged in. Use 'at-bot logout' first to login with a different account."
        return 0
    fi
    
    # Get credentials if not provided via environment
    if [ -z "$identifier" ]; then
        read_secure "Bluesky handle (e.g., user.bsky.social): " identifier
    fi
    
    if [ -z "$password" ]; then
        read_password "App password (will not be stored): " password
    fi
    
    if [ -z "$identifier" ] || [ -z "$password" ]; then
        error "Handle and password are required"
        return 1
    fi
    
    echo "Authenticating..."
    
    # Create session using AT Protocol
    local request_data
    request_data=$(cat <<EOF
{
    "identifier": "$identifier",
    "password": "$password"
}
EOF
)
    
    local response
    response=$(api_request POST "/xrpc/com.atproto.server.createSession" "$request_data")
    
    # Check for errors
    if echo "$response" | grep -q '"error"'; then
        local error_msg
        error_msg=$(echo "$response" | grep -o '"message":"[^"]*"' | cut -d'"' -f4)
        error "Login failed: ${error_msg:-Unknown error}"
        return 1
    fi
    
    # Save session
    echo "$response" > "$SESSION_FILE"
    chmod 600 "$SESSION_FILE"
    
    local handle
    handle=$(echo "$response" | grep -o '"handle":"[^"]*"' | cut -d'"' -f4)
    success "Successfully logged in as: $handle"
    
    return 0
}

# Logout and clear session
atproto_logout() {
    if [ ! -f "$SESSION_FILE" ]; then
        warning "Not currently logged in"
        return 0
    fi
    
    rm -f "$SESSION_FILE"
    success "Logged out successfully"
}

# Display current user
atproto_whoami() {
    if [ ! -f "$SESSION_FILE" ]; then
        error "Not logged in. Run 'at-bot login' first."
        return 1
    fi
    
    local handle did
    handle=$(grep -o '"handle":"[^"]*"' "$SESSION_FILE" | cut -d'"' -f4)
    did=$(grep -o '"did":"[^"]*"' "$SESSION_FILE" | cut -d'"' -f4)
    
    echo "Logged in as:"
    echo "  Handle: $handle"
    echo "  DID: $did"
}

# Get access token from session
get_access_token() {
    if [ ! -f "$SESSION_FILE" ]; then
        return 1
    fi
    
    grep -o '"accessJwt":"[^"]*"' "$SESSION_FILE" | cut -d'"' -f4
}
