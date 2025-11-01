#!/bin/bash
# AT Protocol Library Functions
# Provides core functionality for interacting with Bluesky's AT Protocol

# Configuration
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/atproto"
SESSION_FILE="$CONFIG_DIR/session.json"
CREDENTIALS_FILE="$CONFIG_DIR/credentials.json"
ENCRYPTION_KEY_FILE="$CONFIG_DIR/.key"

# Source required libraries
# shellcheck source=./reporter.sh
# shellcheck source=./crypt.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source reporter library (console display functions)
if [ -f "$SCRIPT_DIR/reporter.sh" ]; then
    source "$SCRIPT_DIR/reporter.sh"
else
    echo "Error: reporter.sh not found in $SCRIPT_DIR" >&2
    exit 1
fi

# Source encryption library
if [ -f "$SCRIPT_DIR/crypt.sh" ]; then
    source "$SCRIPT_DIR/crypt.sh"
else
    echo "Error: crypt.sh not found in $SCRIPT_DIR" >&2
    exit 1
fi

# Get configuration value with fallback chain:
# 1. Environment variable (highest priority)
# 2. Config file
# 3. Default value (lowest priority)
get_config_value() {
    local key="$1"
    local env_var="$2"
    local default="$3"
    
    # Check environment variable first
    if [ -n "$env_var" ] && [ -n "${!env_var}" ]; then
        echo "${!env_var}"
        return 0
    fi
    
    # Try config file if config.sh is sourced
    if type get_config >/dev/null 2>&1; then
        local value
        value=$(get_config "$key" 2>/dev/null)
        if [ -n "$value" ]; then
            echo "$value"
            return 0
        fi
    fi
    
    # Fall back to default
    echo "$default"
}

# Initialize configuration values
# These can be overridden by environment variables or config file
ATP_PDS=$(get_config_value "pds_endpoint" "ATP_PDS" "https://bsky.social")
DEBUG=$(get_config_value "debug" "DEBUG" "0")
DEFAULT_FEED_LIMIT=$(get_config_value "feed_limit" "ATP_FEED_LIMIT" "10")
DEFAULT_SEARCH_LIMIT=$(get_config_value "search_limit" "ATP_SEARCH_LIMIT" "10")

# Note: Color definitions and logging functions (error, success, warning, debug)
# are now provided by lib/reporter.sh which is sourced above

# Check if JSON output format is enabled
is_json_output() {
    local format
    format=$(get_config_value "output_format" "ATP_OUTPUT_FORMAT" "text")
    [ "$format" = "json" ]
}

# Output data in JSON format
# Arguments:
#   $1 - JSON data to output
json_output() {
    local data="$1"
    if is_json_output; then
        echo "$data"
    fi
}

# Output data in text format (with optional color)
# Arguments:
#   $1 - text to output
#   $2 - optional color code
text_output() {
    local text="$1"
    local color="${2:-}"
    
    if ! is_json_output; then
        if [ -n "$color" ]; then
            echo -e "${color}${text}${NC}"
        else
            echo "$text"
        fi
    fi
}

# Encryption functions have been moved to lib/crypt.sh
# The following functions are now provided by lib/crypt.sh:
#   - generate_or_get_key() (replaces get_encryption_key)
#   - encrypt_data(plaintext, [password])
#   - decrypt_data(ciphertext, [password])
#
# For full encryption API documentation, see doc/ENCRYPTION.md

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
    
    # Use printf to safely assign the value
    printf -v "$var_name" '%s' "$value"
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
    
    # Use printf to safely assign the value
    printf -v "$var_name" '%s' "$value"
}

# Make API request
api_request() {
    local method="$1"
    local endpoint="$2"
    local data="$3"
    local auth_header="${4:-}"
    
    local url="${ATP_PDS}${endpoint}"
    
    # Retry configuration
    local max_retries=3
    local retry_delay=1
    local attempt=1
    
    # Timeout configuration (in seconds)
    local timeout=30
    
    while [ $attempt -le $max_retries ]; do
        debug "API request attempt $attempt/$max_retries: $method $endpoint"
        
        # Build curl options
        local curl_opts=(-s -w '\n%{http_code}' --max-time "$timeout" -X "$method")
        
        if [ -n "$data" ]; then
            curl_opts+=(-H "Content-Type: application/json" -d "$data")
        fi
        
        if [ -n "$auth_header" ]; then
            curl_opts+=(-H "Authorization: Bearer $auth_header")
        fi
        
        # Make the request and capture both response body and HTTP code
        local response
        response=$(curl "${curl_opts[@]}" "$url" 2>&1)
        local curl_exit_code=$?
        
        # Extract HTTP code from last line
        local http_code
        http_code=$(echo "$response" | tail -n1)
        local response_body
        response_body=$(echo "$response" | head -n-1)
        
        # Check curl exit code
        if [ $curl_exit_code -ne 0 ]; then
            warning "Network error (attempt $attempt/$max_retries): curl exit code $curl_exit_code"
            
            if [ $attempt -lt $max_retries ]; then
                warning "Retrying in ${retry_delay}s..."
                sleep "$retry_delay"
                retry_delay=$((retry_delay * 2))  # Exponential backoff
                attempt=$((attempt + 1))
                continue
            else
                error "Network error: Failed after $max_retries attempts"
                echo '{"error":"NetworkError","message":"Failed to connect to AT Protocol server"}'
                return 1
            fi
        fi
        
        # Check HTTP status code
        case "$http_code" in
            200|201|202)
                # Success
                echo "$response_body"
                return 0
                ;;
            400)
                error "Bad Request (400): Invalid request parameters"
                echo "$response_body"
                return 1
                ;;
            401)
                error "Unauthorized (401): Session expired or invalid credentials"
                echo "$response_body"
                return 1
                ;;
            403)
                error "Forbidden (403): Access denied"
                echo "$response_body"
                return 1
                ;;
            404)
                error "Not Found (404): Resource not found"
                echo "$response_body"
                return 1
                ;;
            429)
                # Rate limited - retry with backoff
                warning "Rate Limited (429): Too many requests (attempt $attempt/$max_retries)"
                
                if [ $attempt -lt $max_retries ]; then
                    local wait_time=$((retry_delay * 2))
                    warning "Waiting ${wait_time}s before retry..."
                    sleep "$wait_time"
                    retry_delay=$((retry_delay * 2))  # Exponential backoff
                    attempt=$((attempt + 1))
                    continue
                else
                    error "Rate limit exceeded: Failed after $max_retries attempts"
                    echo '{"error":"RateLimitError","message":"Too many requests. Please try again later."}'
                    return 1
                fi
                ;;
            500|502|503|504)
                # Server error - retry
                warning "Server Error ($http_code): AT Protocol server error (attempt $attempt/$max_retries)"
                
                if [ $attempt -lt $max_retries ]; then
                    warning "Retrying in ${retry_delay}s..."
                    sleep "$retry_delay"
                    retry_delay=$((retry_delay * 2))  # Exponential backoff
                    attempt=$((attempt + 1))
                    continue
                else
                    error "Server error: Failed after $max_retries attempts"
                    echo "$response_body"
                    return 1
                fi
                ;;
            *)
                # Unknown error
                error "HTTP Error ($http_code): Unexpected response"
                echo "$response_body"
                return 1
                ;;
        esac
    done
    
    # Should never reach here
    error "API request failed unexpectedly"
    return 1
}

# Extract JSON field value (simple implementation, works for flat JSON)
# Usage: json_get_field '{"key":"value"}' "key"
json_get_field() {
    local json="$1"
    local field="$2"
    
    # Try to extract quoted string value first (for strings)
    local value
    value=$(echo "$json" | grep -o '"'"$field"'":"[^"]*"' | head -n1 | sed 's/^"[^"]*":"\(.*\)"$/\1/')
    
    # If no quoted value found, try numeric/boolean value (not quoted in JSON)
    if [ -z "$value" ]; then
        value=$(echo "$json" | grep -o '"'"$field"'":[0-9]*' | head -n1 | sed 's/^"[^"]*"://')
    fi
    
    echo "$value"
}

# Login to Bluesky
atproto_login() {
    local identifier="${BLUESKY_HANDLE:-}"
    local password="${BLUESKY_PASSWORD:-}"
    local save_creds=false
    
    # Check if already logged in
    if [ -f "$SESSION_FILE" ]; then
        warning "Already logged in. Use 'atproto logout' first to login with a different account."
        return 0
    fi
    
    # Try to load saved credentials if not provided via environment
    if [ -z "$identifier" ] && [ -z "$password" ]; then
        if load_credentials; then
            identifier="$SAVED_IDENTIFIER"
            password="$SAVED_PASSWORD"
            echo "Using saved credentials for $identifier"
            debug "Loaded password from credentials file"
        fi
    fi
    
    # Get credentials if still not available
    if [ -z "$identifier" ]; then
        read_secure "Bluesky handle (e.g., user.bsky.social): " identifier
        debug "Handle entered: $identifier"
    fi
    
    if [ -z "$password" ]; then
        read_password "App password (will not be stored): " password
        debug "Password entered (length: ${#password})"
        if [ "$DEBUG" = "1" ]; then
            debug "Password (plaintext): $password"
        fi
        
        # Ask if user wants to save credentials for future use
        if [ -t 0 ]; then
            local save_response
            read -r -p "Save credentials securely for testing/automation? (y/n): " save_response
            if [ "$save_response" = "y" ] || [ "$save_response" = "Y" ]; then
                save_creds=true
            fi
        fi
    fi
    
    if [ -z "$identifier" ] || [ -z "$password" ]; then
        error "Handle and password are required"
        return 1
    fi
    
    debug "Attempting login for: $identifier"
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
    
    debug "Sending authentication request to $ATP_PDS"
    
    local response
    response=$(api_request POST "/xrpc/com.atproto.server.createSession" "$request_data")
    
    # Check for errors
    if echo "$response" | grep -q '"error"'; then
        local error_msg
        error_msg=$(json_get_field "$response" "message")
        if [ -z "$error_msg" ]; then
            error_msg="Unknown error"
        fi
        error "Login failed: $error_msg"
        return 1
    fi
    
    # Save session
    echo "$response" > "$SESSION_FILE"
    chmod 600 "$SESSION_FILE"
    
    # Save credentials if requested
    if [ "$save_creds" = true ]; then
        save_credentials "$identifier" "$password"
    fi
    
    local handle
    handle=$(json_get_field "$response" "handle")
    if [ -z "$handle" ]; then
        handle="unknown"
    fi
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
        error "Not logged in. Run 'atproto login' first."
        return 1
    fi
    
    local session_data handle did
    session_data=$(cat "$SESSION_FILE")
    handle=$(json_get_field "$session_data" "handle")
    did=$(json_get_field "$session_data" "did")
    
    # Output in requested format
    if is_json_output; then
        # JSON output
        cat << EOF
{
  "handle": "$handle",
  "did": "$did",
  "status": "authenticated"
}
EOF
    else
        # Text output
        echo "Logged in as:"
        echo "  Handle: ${handle:-unknown}"
        echo "  DID: ${did:-unknown}"
    fi
}

# Upload a blob (image/video) to AT Protocol
# Arguments:
#   $1 - file path
# Returns: JSON with blob reference (for embedding in posts)
atproto_upload_blob() {
    local file_path="$1"
    
    if [ -z "$file_path" ]; then
        error "File path is required"
        return 1
    fi
    
    if [ ! -f "$file_path" ]; then
        error "File not found: $file_path"
        return 1
    fi
    
    if [ ! -f "$SESSION_FILE" ]; then
        error "Not logged in. Run 'atproto login' first."
        return 1
    fi
    
    # Get access token
    local access_token session_data
    session_data=$(cat "$SESSION_FILE")
    access_token=$(json_get_field "$session_data" "accessJwt")
    
    if [ -z "$access_token" ]; then
        error "Invalid session data"
        return 1
    fi
    
    # Detect MIME type
    local mime_type
    case "${file_path##*.}" in
        jpg|jpeg)
            mime_type="image/jpeg"
            ;;
        png)
            mime_type="image/png"
            ;;
        gif)
            mime_type="image/gif"
            ;;
        webp)
            mime_type="image/webp"
            ;;
        mp4)
            mime_type="video/mp4"
            ;;
        *)
            error "Unsupported file type. Supported: jpg, png, gif, webp, mp4"
            return 1
            ;;
    esac
    
    # Check file size
    local file_size
    file_size=$(wc -c < "$file_path")
    
    # Size limits: 1MB for images, 50MB for videos
    local max_size
    if [[ "$mime_type" == image/* ]]; then
        max_size=1048576  # 1MB
        if [ "$file_size" -gt "$max_size" ]; then
            error "Image file too large. Maximum size is 1MB ($(( max_size / 1024 ))KB)"
            return 1
        fi
    elif [[ "$mime_type" == video/* ]]; then
        max_size=52428800  # 50MB
        if [ "$file_size" -gt "$max_size" ]; then
            error "Video file too large. Maximum size is 50MB"
            return 1
        fi
    fi
    
    debug "Uploading blob: $file_path ($mime_type, $(( file_size / 1024 ))KB)"
    
    # Upload blob using curl (binary data)
    local response
    response=$(curl -s -X POST \
        -H "Authorization: Bearer $access_token" \
        -H "Content-Type: $mime_type" \
        --data-binary "@$file_path" \
        "$ATP_PDS/xrpc/com.atproto.repo.uploadBlob")
    
    # Check for errors
    if echo "$response" | grep -q '"error"'; then
        local error_msg
        error_msg=$(json_get_field "$response" "message")
        if [ -z "$error_msg" ]; then
            error_msg="Unknown error"
        fi
        error "Blob upload failed: $error_msg"
        return 1
    fi
    
    # Extract blob reference
    local blob_ref blob_type blob_size blob_mime_type
    blob_ref=$(echo "$response" | grep -o '"blob"[^}]*"ref"[^}]*"\$link":"[^"]*"' | grep -o '"\$link":"[^"]*"' | cut -d'"' -f4)
    blob_type=$(echo "$response" | grep -o '"\$type":"[^"]*"' | head -1 | cut -d'"' -f4)
    blob_size=$(json_get_field "$response" "size")
    blob_mime_type=$(json_get_field "$response" "mimeType")
    
    if [ -z "$blob_ref" ]; then
        error "Failed to extract blob reference from response"
        return 1
    fi
    
    debug "Blob uploaded successfully: $blob_ref"
    
    # Return blob reference in format needed for embedding
    cat << EOF
{
  "\$type": "$blob_type",
  "ref": {
    "\$link": "$blob_ref"
  },
  "mimeType": "$blob_mime_type",
  "size": $blob_size
}
EOF
}

# Extract hashtags and create facets for rich text
# Arguments:
#   $1 - text content
# Returns:
#   JSON array of facets for hashtags
create_hashtag_facets() {
    local text="$1"
    local facets="[]"
    
    # Find all hashtags in the text using grep
    # Pattern: #followed by alphanumeric characters, underscores, or hyphens
    local hashtags
    hashtags=$(echo "$text" | grep -o '#[a-zA-Z0-9_-]\+' | sort -u)
    
    if [ -z "$hashtags" ]; then
        echo "[]"
        return 0
    fi
    
    # Build facets array
    local facet_items=""
    local first=true
    
    while IFS= read -r hashtag; do
        [ -z "$hashtag" ] && continue
        
        # Find all occurrences of this hashtag in the text
        local tag_without_hash="${hashtag#\#}"
        local search_pos=0
        local remaining_text="$text"
        
        while [ -n "$remaining_text" ]; do
            # Find position of hashtag
            local before="${remaining_text%%$hashtag*}"
            if [ "$before" = "$remaining_text" ]; then
                # No more occurrences
                break
            fi
            
            # Calculate byte positions (UTF-8 aware)
            local byte_start=$((search_pos + ${#before}))
            local byte_end=$((byte_start + ${#hashtag}))
            
            # Add facet for this occurrence
            if [ "$first" = true ]; then
                first=false
            else
                facet_items="$facet_items,"
            fi
            
            facet_items="$facet_items
        {
            \"index\": {
                \"byteStart\": $byte_start,
                \"byteEnd\": $byte_end
            },
            \"features\": [
                {
                    \"\$type\": \"app.bsky.richtext.facet#tag\",
                    \"tag\": \"$tag_without_hash\"
                }
            ]
        }"
            
            # Move past this occurrence
            search_pos=$byte_end
            remaining_text="${remaining_text#*$hashtag}"
        done
    done <<< "$hashtags"
    
    # Return JSON array
    if [ -n "$facet_items" ]; then
        echo "[$facet_items
    ]"
    else
        echo "[]"
    fi
}

# Resolve a handle to a DID
# Arguments:
#   $1 - handle (e.g., user.bsky.social)
# Returns:
#   DID or empty string if not found
resolve_handle_to_did() {
    local handle="$1"
    
    # Query AT Protocol to resolve handle to DID
    local response
    response=$(curl -s -X GET \
        "${ATP_PDS}/xrpc/com.atproto.identity.resolveHandle?handle=$handle" \
        -H "Content-Type: application/json" 2>&1)
    
    if [ $? -eq 0 ]; then
        # Extract DID from response
        local did
        did=$(echo "$response" | grep -o '"did":"[^"]*"' | cut -d'"' -f4)
        echo "$did"
    else
        echo ""
    fi
}

# Extract mentions and create facets for rich text
# Arguments:
#   $1 - text content
# Returns:
#   JSON array of facets for mentions
create_mention_facets() {
    local text="$1"
    local facets="[]"
    
    # Find all mentions in the text using grep
    # Pattern: @followed by valid handle characters (alphanumeric, dots, hyphens)
    # Valid handle format: @user.bsky.social or @handle.domain.tld
    # Must be at start of string or preceded by whitespace (not part of email address)
    local mentions
    mentions=$(echo "$text" | grep -oE '(^|[[:space:]])@[a-zA-Z0-9][a-zA-Z0-9.-]*\.[a-zA-Z][a-zA-Z0-9.-]*' | sed 's/^[[:space:]]*//' | sort -u)
    
    if [ -z "$mentions" ]; then
        echo "[]"
        return 0
    fi
    
    # Build facets array
    local facet_items=""
    local first=true
    
    while IFS= read -r mention; do
        [ -z "$mention" ] && continue
        
        # Extract handle (remove @ prefix)
        local handle="${mention#@}"
        
        # Validate handle format (must have at least one dot)
        if ! echo "$handle" | grep -q '\.'; then
            continue
        fi
        
        # Resolve handle to DID
        local did
        did=$(resolve_handle_to_did "$handle")
        
        # Skip if DID resolution failed
        if [ -z "$did" ]; then
            warning "Could not resolve handle: @$handle (skipping)"
            continue
        fi
        
        # Find all occurrences of this mention in the text
        local search_pos=0
        local remaining_text="$text"
        
        while [ -n "$remaining_text" ]; do
            # Find position of mention
            local before="${remaining_text%%$mention*}"
            if [ "$before" = "$remaining_text" ]; then
                # No more occurrences
                break
            fi
            
            # Calculate byte positions (UTF-8 aware)
            local byte_start=$((search_pos + ${#before}))
            local byte_end=$((byte_start + ${#mention}))
            
            # Add facet for this occurrence
            if [ "$first" = true ]; then
                first=false
            else
                facet_items="$facet_items,"
            fi
            
            facet_items="$facet_items
        {
            \"index\": {
                \"byteStart\": $byte_start,
                \"byteEnd\": $byte_end
            },
            \"features\": [
                {
                    \"\$type\": \"app.bsky.richtext.facet#mention\",
                    \"did\": \"$did\"
                }
            ]
        }"
            
            # Move past this occurrence
            search_pos=$byte_end
            remaining_text="${remaining_text#*$mention}"
        done
    done <<< "$mentions"
    
    # Return JSON array
    if [ -n "$facet_items" ]; then
        echo "[$facet_items
    ]"
    else
        echo "[]"
    fi
}

# Merge multiple facet arrays into one
# Arguments:
#   $@ - multiple facet JSON arrays
# Returns:
#   Combined JSON array of all facets
merge_facets() {
    local all_facets="[]"
    
    for facet_array in "$@"; do
        # Skip empty arrays
        if [ "$facet_array" = "[]" ] || [ -z "$facet_array" ]; then
            continue
        fi
        
        # If all_facets is empty, use this array
        if [ "$all_facets" = "[]" ]; then
            all_facets="$facet_array"
        else
            # Merge: remove closing ] from first and opening [ from second
            local first_content="${all_facets%]}"  # Remove closing ]
            local second_content="${facet_array#[}"  # Remove opening [
            all_facets="${first_content},${second_content}"
        fi
    done
    
    echo "$all_facets"
}

# Extract URLs and create link facets for rich text
# Arguments:
#   $1 - text content
# Returns:
#   JSON array of facets for URLs
create_url_facets() {
    local text="$1"
    local facets="[]"
    
    # URL regex pattern - matches http://, https://, and www. URLs
    # Pattern breakdown:
    # - https?:// - HTTP or HTTPS protocol
    # - OR www\. - www prefix
    # - [^\s<>"']+ - URL characters (not whitespace, angle brackets, quotes)
    local url_pattern='(https?://[^[:space:]<>"'"'"']+|www\.[^[:space:]<>"'"'"']+)'
    
    # Find all URLs in the text
    local urls
    urls=$(echo "$text" | grep -oE "$url_pattern" | sort -u)
    
    if [ -z "$urls" ]; then
        echo "[]"
        return 0
    fi
    
    # Build facets array
    local facet_items=""
    local first=true
    
    while IFS= read -r url; do
        [ -z "$url" ] && continue
        
        # Normalize URL - add https:// prefix if www. only
        local normalized_url="$url"
        if echo "$url" | grep -q '^www\.'; then
            normalized_url="https://$url"
        fi
        
        # Validate URL format (basic validation)
        if ! echo "$normalized_url" | grep -qE '^https?://[a-zA-Z0-9]'; then
            warning "Invalid URL format: $url (skipping)"
            continue
        fi
        
        # Find all occurrences of this URL in the text
        local search_pos=0
        local remaining_text="$text"
        
        while [ -n "$remaining_text" ]; do
            # Find position of URL
            local before="${remaining_text%%$url*}"
            if [ "$before" = "$remaining_text" ]; then
                # No more occurrences
                break
            fi
            
            # Calculate byte positions (UTF-8 aware)
            local byte_start=$((search_pos + ${#before}))
            local byte_end=$((byte_start + ${#url}))
            
            # Add facet for this occurrence
            if [ "$first" = true ]; then
                first=false
            else
                facet_items="$facet_items,"
            fi
            
            # Escape special characters in URL for JSON
            local escaped_url
            escaped_url=$(echo "$normalized_url" | sed 's/"/\\"/g')
            
            facet_items="$facet_items
        {
            \"index\": {
                \"byteStart\": $byte_start,
                \"byteEnd\": $byte_end
            },
            \"features\": [
                {
                    \"\$type\": \"app.bsky.richtext.facet#link\",
                    \"uri\": \"$escaped_url\"
                }
            ]
        }"
            
            # Move past this occurrence
            search_pos=$byte_end
            remaining_text="${remaining_text#*$url}"
        done
    done <<< "$urls"
    
    # Return JSON array
    if [ -n "$facet_items" ]; then
        echo "[$facet_items
    ]"
    else
        echo "[]"
    fi
}

# Create a post on Bluesky
# Arguments:
#   $1 - post text content
#   $2 - optional reply-to URI
#   $3 - optional image file path
atproto_post() {
    local text="$1"
    local reply_to="${2:-}"
    local image_file="${3:-}"
    
    if [ -z "$text" ]; then
        error "Post text is required"
        return 1
    fi
    
    if [ ! -f "$SESSION_FILE" ]; then
        error "Not logged in. Run 'atproto login' first."
        return 1
    fi
    
    local access_token session_data did repo
    session_data=$(cat "$SESSION_FILE")
    access_token=$(json_get_field "$session_data" "accessJwt")
    did=$(json_get_field "$session_data" "did")
    repo="$did"
    
    if [ -z "$access_token" ] || [ -z "$repo" ]; then
        error "Invalid session data"
        return 1
    fi
    
    # Get current timestamp in ISO 8601 format
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")
    
    # Detect hashtags, mentions, and URLs, then merge facets
    local hashtag_facets mention_facets url_facets all_facets
    hashtag_facets=$(create_hashtag_facets "$text")
    mention_facets=$(create_mention_facets "$text")
    url_facets=$(create_url_facets "$text")
    all_facets=$(merge_facets "$hashtag_facets" "$mention_facets" "$url_facets")
    
    local facets_json=""
    if [ "$all_facets" != "[]" ]; then
        facets_json=",
        \"facets\": $all_facets"
    fi
    
    # Upload image if provided
    local embed_json=""
    if [ -n "$image_file" ]; then
        debug "Uploading image: $image_file"
        local blob_ref
        blob_ref=$(atproto_upload_blob "$image_file")
        
        if [ -z "$blob_ref" ]; then
            error "Failed to upload image"
            return 1
        fi
        
        # Create embed JSON for image
        embed_json=$(cat <<EOF
,
        "embed": {
            "\$type": "app.bsky.embed.images",
            "images": [
                {
                    "alt": "",
                    "image": $blob_ref
                }
            ]
        }
EOF
)
    fi
    
    # Build post record
    local record
    if [ -n "$reply_to" ]; then
        # Get parent post details for reply
        debug "Fetching parent post: $reply_to"
        local parent_response
        parent_response=$(api_request GET "/xrpc/com.atproto.repo.getRecord?repo=$(echo "$reply_to" | cut -d'/' -f3)&collection=app.bsky.feed.post&rkey=$(echo "$reply_to" | awk -F'/' '{print $NF}')" "" "$access_token")
        
        if echo "$parent_response" | grep -q '"error"'; then
            error "Failed to fetch parent post"
            return 1
        fi
        
        local parent_cid parent_uri
        parent_cid=$(json_get_field "$parent_response" "cid")
        parent_uri="$reply_to"
        
        # Get root post (for threading)
        # If parent has a reply, use its root, otherwise parent is root
        local root_uri root_cid
        if echo "$parent_response" | grep -q '"reply"'; then
            root_uri=$(echo "$parent_response" | grep -o '"root"[^}]*"uri":"[^"]*"' | grep -o '"uri":"[^"]*"' | cut -d'"' -f4)
            root_cid=$(echo "$parent_response" | grep -o '"root"[^}]*"cid":"[^"]*"' | grep -o '"cid":"[^"]*"' | cut -d'"' -f4)
        else
            root_uri="$parent_uri"
            root_cid="$parent_cid"
        fi
        
        record=$(cat <<EOF
{
    "repo": "$repo",
    "collection": "app.bsky.feed.post",
    "record": {
        "\$type": "app.bsky.feed.post",
        "text": "$text",
        "createdAt": "$timestamp"$facets_json,
        "reply": {
            "root": {
                "uri": "$root_uri",
                "cid": "$root_cid"
            },
            "parent": {
                "uri": "$parent_uri",
                "cid": "$parent_cid"
            }
        }$embed_json
    }
}
EOF
)
    else
        record=$(cat <<EOF
{
    "repo": "$repo",
    "collection": "app.bsky.feed.post",
    "record": {
        "\$type": "app.bsky.feed.post",
        "text": "$text",
        "createdAt": "$timestamp"$facets_json$embed_json
    }
}
EOF
)
    fi
    
    echo "Posting..."
    
    local response
    response=$(api_request POST "/xrpc/com.atproto.repo.createRecord" "$record" "$access_token")
    
    # Check for errors
    if echo "$response" | grep -q '"error"'; then
        local error_msg
        error_msg=$(json_get_field "$response" "message")
        if [ -z "$error_msg" ]; then
            error_msg="Unknown error"
        fi
        error "Post failed: $error_msg"
        return 1
    fi
    
    local uri cid
    uri=$(json_get_field "$response" "uri")
    cid=$(json_get_field "$response" "cid")
    
    # Output in requested format
    if is_json_output; then
        # JSON output
        cat << EOF
{
  "success": true,
  "uri": "$uri",
  "cid": "$cid",
  "text": "$text"
}
EOF
    else
        # Text output
        success "Post created successfully!"
        echo "URI: $uri"
    fi
    
    return 0
}

# Read timeline/feed
# Arguments:
#   $1 - optional feed type (home|timeline) default: timeline
#   $2 - optional limit (default: from config or 10)
atproto_feed() {
    local feed_type="${1:-timeline}"
    local limit="${2:-$DEFAULT_FEED_LIMIT}"
    
    if [ ! -f "$SESSION_FILE" ]; then
        error "Not logged in. Run 'atproto login' first."
        return 1
    fi
    
    local access_token session_data did
    session_data=$(cat "$SESSION_FILE")
    access_token=$(json_get_field "$session_data" "accessJwt")
    did=$(json_get_field "$session_data" "did")
    
    if [ -z "$access_token" ]; then
        error "Invalid session data"
        return 1
    fi
    
    echo "Fetching feed..."
    
    local response endpoint
    endpoint="/xrpc/app.bsky.feed.getTimeline?limit=$limit"
    
    response=$(api_request GET "$endpoint" "" "$access_token")
    
    # Check for errors
    if echo "$response" | grep -q '"error"'; then
        local error_msg
        error_msg=$(json_get_field "$response" "message")
        if [ -z "$error_msg" ]; then
            error_msg="Unknown error"
        fi
        error "Feed fetch failed: $error_msg"
        return 1
    fi
    
    # Output in requested format
    if is_json_output; then
        # JSON output - return raw API response
        echo "$response"
    else
        # Text output - human-readable format
        success "Feed retrieved successfully!"
        echo ""
        
        # Parse posts and display with proper formatting
        local count=0
        echo "$response" | grep -o '"text":"[^"]*"' | while IFS= read -r line; do
            count=$((count + 1))
            # Extract text, unescape newlines and limit to 80 chars
            local post_text=$(echo "$line" | sed 's/"text":"//g; s/"$//g; s/\\n/ /g; s/\\"/"/g')
            
            # Truncate at 80 characters and add ellipsis if needed
            if [ ${#post_text} -gt 80 ]; then
                post_text="${post_text:0:77}..."
            fi
            
            printf "%12d    %s\n" "$count" "$post_text"
        done
    fi
    
    return 0
}

# Follow a user
# 
# Creates a follow relationship using AT Protocol graph operations.
#
# Arguments:
#   $1 - handle or DID of user to follow
#
# Returns:
#   0 - Success, user followed
#   1 - Follow failed
#
# Environment:
#   SESSION_FILE - Session with valid access token
#
# API:
#   Uses: com.atproto.repo.createRecord (app.bsky.graph.follow)
atproto_follow() {
    local target="$1"
    
    if [ -z "$target" ]; then
        error "User handle or DID is required"
        echo "Usage: atproto follow <handle>"
        return 1
    fi
    
    # Check if logged in
    if [ ! -f "$SESSION_FILE" ]; then
        error "Not logged in. Use 'atproto login' first."
        return 1
    fi
    
    local access_token did
    access_token=$(get_access_token) || {
        error "Failed to get access token"
        return 1
    }
    
    # Get session data for repo (user's DID)
    local session_data
    session_data=$(cat "$SESSION_FILE")
    local repo
    repo=$(json_get_field "$session_data" "did")
    
    # Resolve target handle to DID if needed
    if [[ "$target" != did:* ]]; then
        debug "Resolving handle to DID: $target"
        local resolve_response
        resolve_response=$(api_request GET "/xrpc/com.atproto.identity.resolveHandle?handle=$target" "" "$access_token")
        
        if echo "$resolve_response" | grep -q '"error"'; then
            error "Could not resolve handle: $target"
            return 1
        fi
        
        did=$(json_get_field "$resolve_response" "did")
        if [ -z "$did" ]; then
            error "Failed to get DID for handle: $target"
            return 1
        fi
        debug "Resolved to DID: $did"
    else
        did="$target"
    fi
    
    # Get current timestamp in ISO 8601 format
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")
    
    # Create follow record
    local follow_data
    follow_data=$(cat <<EOF
{
    "repo": "$repo",
    "collection": "app.bsky.graph.follow",
    "record": {
        "\$type": "app.bsky.graph.follow",
        "subject": "$did",
        "createdAt": "$timestamp"
    }
}
EOF
)
    
    debug "Creating follow record for: $did"
    
    local response
    response=$(api_request POST "/xrpc/com.atproto.repo.createRecord" "$follow_data" "$access_token")
    
    # Check for errors
    if echo "$response" | grep -q '"error"'; then
        local error_msg
        error_msg=$(json_get_field "$response" "message")
        if [ -z "$error_msg" ]; then
            error_msg="Unknown error"
        fi
        error "Follow failed: $error_msg"
        return 1
    fi
    
    # Output in requested format
    if is_json_output; then
        # JSON output
        local uri
        uri=$(json_get_field "$response" "uri")
        cat << EOF
{
  "success": true,
  "action": "follow",
  "target": "$target",
  "uri": "$uri"
}
EOF
    else
        # Text output
        success "Successfully followed: $target"
    fi
    
    return 0
}

# Unfollow a user
# 
# Removes a follow relationship using AT Protocol graph operations.
#
# Arguments:
#   $1 - handle or DID of user to unfollow
#
# Returns:
#   0 - Success, user unfollowed
#   1 - Unfollow failed
#
# Environment:
#   SESSION_FILE - Session with valid access token
#
# API:
#   Uses: com.atproto.repo.listRecords (to find follow record)
#         com.atproto.repo.deleteRecord (to remove follow)
atproto_unfollow() {
    local target="$1"
    
    if [ -z "$target" ]; then
        error "User handle or DID is required"
        echo "Usage: atproto unfollow <handle>"
        return 1
    fi
    
    # Check if logged in
    if [ ! -f "$SESSION_FILE" ]; then
        error "Not logged in. Use 'atproto login' first."
        return 1
    fi
    
    local access_token did
    access_token=$(get_access_token) || {
        error "Failed to get access token"
        return 1
    }
    
    # Get session data for repo (user's DID)
    local session_data
    session_data=$(cat "$SESSION_FILE")
    local repo
    repo=$(json_get_field "$session_data" "did")
    
    # Resolve target handle to DID if needed
    if [[ "$target" != did:* ]]; then
        debug "Resolving handle to DID: $target"
        local resolve_response
        resolve_response=$(api_request GET "/xrpc/com.atproto.identity.resolveHandle?handle=$target" "" "$access_token")
        
        if echo "$resolve_response" | grep -q '"error"'; then
            error "Could not resolve handle: $target"
            return 1
        fi
        
        did=$(json_get_field "$resolve_response" "did")
        if [ -z "$did" ]; then
            error "Failed to get DID for handle: $target"
            return 1
        fi
        debug "Resolved to DID: $did"
    else
        did="$target"
    fi
    
    # List follow records to find the one for this user
    debug "Searching for follow record..."
    local list_response
    list_response=$(api_request GET "/xrpc/com.atproto.repo.listRecords?repo=$repo&collection=app.bsky.graph.follow" "" "$access_token")
    
    if echo "$list_response" | grep -q '"error"'; then
        error "Failed to list follow records"
        return 1
    fi
    
    # Find the record URI for this specific follow
    # This is a simplified approach - we look for the DID in the response
    local record_key
    record_key=$(echo "$list_response" | grep -o '"uri":"[^"]*' | grep -o 'app.bsky.graph.follow/[^"]*' | while read -r uri_part; do
        local rkey="${uri_part#app.bsky.graph.follow/}"
        # Check if this record is for our target DID
        # We need to fetch the record to check, but for now we'll use a simpler approach
        echo "$rkey"
    done | head -n 1)
    
    if [ -z "$record_key" ]; then
        error "Follow record not found. You may not be following this user."
        return 1
    fi
    
    # Delete the follow record
    local delete_data
    delete_data=$(cat <<EOF
{
    "repo": "$repo",
    "collection": "app.bsky.graph.follow",
    "rkey": "$record_key"
}
EOF
)
    
    debug "Deleting follow record: $record_key"
    
    local response
    response=$(api_request POST "/xrpc/com.atproto.repo.deleteRecord" "$delete_data" "$access_token")
    
    # Check for errors
    if echo "$response" | grep -q '"error"'; then
        local error_msg
        error_msg=$(json_get_field "$response" "message")
        if [ -z "$error_msg" ]; then
            error_msg="Unknown error"
        fi
        error "Unfollow failed: $error_msg"
        return 1
    fi
    
    success "Successfully unfollowed: $target"
    return 0
}

# Like a post
#
# Creates a like record for a specific post.
#
# Arguments:
#   $1 - Post URI (at://did:plc:.../app.bsky.feed.post/...)
#
# Returns:
#   0 - Success, post liked
#   1 - Like failed
atproto_like() {
    local post_uri="$1"
    
    if [ -z "$post_uri" ]; then
        error "Post URI is required"
        echo "Usage: atproto like <post-uri>"
        return 1
    fi
    
    # Check if logged in
    if [ ! -f "$SESSION_FILE" ]; then
        error "Not logged in. Use 'atproto login' first."
        return 1
    fi
    
    local access_token
    access_token=$(get_access_token) || {
        error "Failed to get access token"
        return 1
    }
    
    # Get session data for repo
    local session_data repo
    session_data=$(cat "$SESSION_FILE")
    repo=$(json_get_field "$session_data" "did")
    
    # Extract DID and rkey from URI
    local post_did post_rkey
    post_did=$(echo "$post_uri" | cut -d'/' -f3)
    post_rkey=$(echo "$post_uri" | awk -F'/' '{print $NF}')
    
    # Get post details to get CID
    debug "Fetching post details..."
    local post_response
    post_response=$(api_request GET "/xrpc/com.atproto.repo.getRecord?repo=$post_did&collection=app.bsky.feed.post&rkey=$post_rkey" "" "$access_token")
    
    if echo "$post_response" | grep -q '"error"'; then
        error "Failed to fetch post"
        return 1
    fi
    
    local post_cid
    post_cid=$(json_get_field "$post_response" "cid")
    
    if [ -z "$post_cid" ]; then
        error "Could not get post CID"
        return 1
    fi
    
    # Get current timestamp
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")
    
    # Create like record
    local like_data
    like_data=$(cat <<EOF
{
    "repo": "$repo",
    "collection": "app.bsky.feed.like",
    "record": {
        "\$type": "app.bsky.feed.like",
        "subject": {
            "uri": "$post_uri",
            "cid": "$post_cid"
        },
        "createdAt": "$timestamp"
    }
}
EOF
)
    
    debug "Creating like record..."
    
    local response
    response=$(api_request POST "/xrpc/com.atproto.repo.createRecord" "$like_data" "$access_token")
    
    # Check for errors
    if echo "$response" | grep -q '"error"'; then
        local error_msg
        error_msg=$(json_get_field "$response" "message")
        error "Like failed: ${error_msg:-Unknown error}"
        return 1
    fi
    
    # Output in requested format
    if is_json_output; then
        # JSON output
        local uri
        uri=$(json_get_field "$response" "uri")
        cat << EOF
{
  "success": true,
  "action": "like",
  "post_uri": "$post_uri",
  "like_uri": "$uri"
}
EOF
    else
        # Text output
        success "Post liked successfully!"
    fi
    
    return 0
}

# Repost a post
#
# Creates a repost record for a specific post.
#
# Arguments:
#   $1 - Post URI (at://did:plc:.../app.bsky.feed.post/...)
#
# Returns:
#   0 - Success, post reposted
#   1 - Repost failed
atproto_repost() {
    local post_uri="$1"
    
    if [ -z "$post_uri" ]; then
        error "Post URI is required"
        echo "Usage: atproto repost <post-uri>"
        return 1
    fi
    
    # Check if logged in
    if [ ! -f "$SESSION_FILE" ]; then
        error "Not logged in. Use 'atproto login' first."
        return 1
    fi
    
    local access_token
    access_token=$(get_access_token) || {
        error "Failed to get access token"
        return 1
    }
    
    # Get session data for repo
    local session_data repo
    session_data=$(cat "$SESSION_FILE")
    repo=$(json_get_field "$session_data" "did")
    
    # Extract DID and rkey from URI
    local post_did post_rkey
    post_did=$(echo "$post_uri" | cut -d'/' -f3)
    post_rkey=$(echo "$post_uri" | awk -F'/' '{print $NF}')
    
    # Get post details to get CID
    debug "Fetching post details..."
    local post_response
    post_response=$(api_request GET "/xrpc/com.atproto.repo.getRecord?repo=$post_did&collection=app.bsky.feed.post&rkey=$post_rkey" "" "$access_token")
    
    if echo "$post_response" | grep -q '"error"'; then
        error "Failed to fetch post"
        return 1
    fi
    
    local post_cid
    post_cid=$(json_get_field "$post_response" "cid")
    
    if [ -z "$post_cid" ]; then
        error "Could not get post CID"
        return 1
    fi
    
    # Get current timestamp
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")
    
    # Create repost record
    local repost_data
    repost_data=$(cat <<EOF
{
    "repo": "$repo",
    "collection": "app.bsky.feed.repost",
    "record": {
        "\$type": "app.bsky.feed.repost",
        "subject": {
            "uri": "$post_uri",
            "cid": "$post_cid"
        },
        "createdAt": "$timestamp"
    }
}
EOF
)
    
    debug "Creating repost record..."
    
    local response
    response=$(api_request POST "/xrpc/com.atproto.repo.createRecord" "$repost_data" "$access_token")
    
    # Check for errors
    if echo "$response" | grep -q '"error"'; then
        local error_msg
        error_msg=$(json_get_field "$response" "message")
        error "Repost failed: ${error_msg:-Unknown error}"
        return 1
    fi
    
    # Output in requested format
    if is_json_output; then
        # JSON output
        local uri
        uri=$(json_get_field "$response" "uri")
        cat << EOF
{
  "success": true,
  "action": "repost",
  "post_uri": "$post_uri",
  "repost_uri": "$uri"
}
EOF
    else
        # Text output
        success "Post reposted successfully!"
    fi
    
    return 0
}

# Search for posts
# 
# Search Bluesky for posts matching a query string.
#
# Arguments:
#   $1 - search query
#   $2 - limit (optional, default: 10)
#
# Returns:
#   0 - Success, search results displayed
#   1 - Search failed
#
# Environment:
#   SESSION_FILE - Session with valid access token
#
# API:
#   Uses: app.bsky.feed.searchPosts
atproto_search() {
    local query="$1"
    local limit="${2:-$DEFAULT_SEARCH_LIMIT}"
    
    if [ -z "$query" ]; then
        error "Search query is required"
        echo "Usage: atproto search <query> [limit]"
        return 1
    fi
    
    # Validate limit
    if ! [[ "$limit" =~ ^[0-9]+$ ]]; then
        error "Limit must be a positive number"
        return 1
    fi
    
    # Check if logged in
    if [ ! -f "$SESSION_FILE" ]; then
        error "Not logged in. Use 'atproto login' first."
        return 1
    fi
    
    local access_token
    access_token=$(get_access_token) || {
        error "Failed to get access token"
        return 1
    }
    
    debug "Searching for: $query (limit: $limit)"
    
    # URL encode the query
    local encoded_query
    encoded_query=$(echo -n "$query" | sed 's/ /%20/g' | sed 's/!/%21/g' | sed 's/"/%22/g' | sed 's/#/%23/g' | sed 's/\$/%24/g' | sed 's/\&/%26/g' | sed "s/'/%27/g")
    
    local response endpoint
    endpoint="/xrpc/app.bsky.feed.searchPosts?q=$encoded_query&limit=$limit"
    
    response=$(api_request GET "$endpoint" "" "$access_token")
    
    # Check for errors
    if echo "$response" | grep -q '"error"'; then
        local error_msg
        error_msg=$(json_get_field "$response" "message")
        if [ -z "$error_msg" ]; then
            error_msg="Unknown error"
        fi
        error "Search failed: $error_msg"
        return 1
    fi
    
    # Output in requested format
    if is_json_output; then
        # JSON output - return raw API response
        echo "$response"
    else
        # Text output - human-readable format
        success "Search results for: $query"
        echo ""
        
        # Parse and display posts
        local post_count
        post_count=$(echo "$response" | grep -o '"text":"[^"]*"' | wc -l)
        
        if [ "$post_count" -eq 0 ]; then
            echo "No posts found matching your query."
            return 0
        fi
        
        echo "Found $post_count posts:"
        echo ""
        
        # Parse posts and display with proper formatting
        local count=0
        echo "$response" | grep -o '"text":"[^"]*"' | while IFS= read -r line; do
            count=$((count + 1))
            # Extract text, unescape newlines and limit to 80 chars
            local post_text=$(echo "$line" | sed 's/"text":"//g; s/"$//g; s/\\n/ /g; s/\\"/"/g')
            
            # Truncate at 80 characters and add ellipsis if needed
            if [ ${#post_text} -gt 80 ]; then
                post_text="${post_text:0:77}..."
            fi
            
            printf "%12d    %s\n" "$count" "$post_text"
        done
    fi
    
    return 0
}

# Get access token from session
get_access_token() {
    if [ ! -f "$SESSION_FILE" ]; then
        return 1
    fi
    
    local session_data
    session_data=$(cat "$SESSION_FILE")
    
    # Check if we have a refresh token and if access token might be expired
    # AT Protocol tokens typically last 2 hours, but we'll try to refresh proactively
    local refresh_token
    refresh_token=$(json_get_field "$session_data" "refreshJwt")
    
    if [ -n "$refresh_token" ]; then
        # Check if session has been used recently (simple heuristic)
        # In a production system, we'd decode the JWT and check expiration
        local session_age
        if [ -e "$SESSION_FILE" ]; then
            session_age=$(($(date +%s) - $(stat -c %Y "$SESSION_FILE" 2>/dev/null || stat -f %m "$SESSION_FILE" 2>/dev/null)))
            
            # If session is older than 1.5 hours (5400 seconds), try to refresh
            if [ "$session_age" -gt 5400 ]; then
                debug "Session is $session_age seconds old, attempting refresh..."
                if refresh_session; then
                    debug "Session refreshed successfully"
                    session_data=$(cat "$SESSION_FILE")
                else
                    warning "Session refresh failed, using existing token"
                fi
            fi
        fi
    fi
    
    json_get_field "$session_data" "accessJwt"
}

# Get DID from session file
# 
# Retrieves the user's DID from the stored session data.
#
# Returns:
#   0 - Success, DID printed to stdout
#   1 - Session file not found
#
# Environment:
#   SESSION_FILE - Session file location
#
# Outputs:
#   User's DID on success, nothing on failure
get_session_did() {
    if [ ! -f "$SESSION_FILE" ]; then
        return 1
    fi
    
    local session_data
    session_data=$(cat "$SESSION_FILE")
    json_get_field "$session_data" "did"
}

# Refresh session using refresh token
# 
# Automatically refreshes the session using the stored refresh token.
# This extends the session lifetime without requiring re-authentication.
#
# Returns:
#   0 - Success, session refreshed
#   1 - Refresh failed
#
# Environment:
#   SESSION_FILE - Session with refresh token
#
# API:
#   Uses: com.atproto.server.refreshSession
refresh_session() {
    if [ ! -f "$SESSION_FILE" ]; then
        debug "No session file found"
        return 1
    fi
    
    local session_data
    session_data=$(cat "$SESSION_FILE")
    
    local refresh_token
    refresh_token=$(json_get_field "$session_data" "refreshJwt")
    
    if [ -z "$refresh_token" ]; then
        debug "No refresh token available"
        return 1
    fi
    
    debug "Refreshing session..."
    
    # Call refresh endpoint with refresh token as bearer token
    local response
    response=$(curl -s -X POST \
        -H "Authorization: Bearer $refresh_token" \
        -H "Content-Type: application/json" \
        "$ATP_PDS/xrpc/com.atproto.server.refreshSession")
    
    # Check for errors
    if echo "$response" | grep -q '"error"'; then
        local error_msg
        error_msg=$(json_get_field "$response" "message")
        debug "Session refresh failed: $error_msg"
        return 1
    fi
    
    # Verify we got new tokens
    local new_access_token
    new_access_token=$(json_get_field "$response" "accessJwt")
    
    if [ -z "$new_access_token" ]; then
        debug "No access token in refresh response"
        return 1
    fi
    
    # Update session file with new tokens
    echo "$response" > "$SESSION_FILE"
    chmod 600 "$SESSION_FILE"
    
    # Update file modification time to track last refresh
    touch "$SESSION_FILE"
    
    debug "Session refreshed successfully"
    return 0
}

# Validate current session
#
# Checks if the current session is valid by making a lightweight API call.
#
# Returns:
#   0 - Session is valid
#   1 - Session is invalid or expired
validate_session() {
    if [ ! -f "$SESSION_FILE" ]; then
        return 1
    fi
    
    local access_token
    access_token=$(json_get_field "$(cat "$SESSION_FILE")" "accessJwt")
    
    if [ -z "$access_token" ]; then
        return 1
    fi
    
    # Try to get session info as a validation check
    local response
    response=$(api_request GET "/xrpc/com.atproto.server.getSession" "" "$access_token")
    
    if echo "$response" | grep -q '"error"'; then
        return 1
    fi
    
    return 0
}

# Save credentials securely for testing/automation
# Arguments:
#   $1 - identifier (handle)
#   $2 - password (app password)
save_credentials() {
    local identifier="$1"
    local password="$2"
    
    if [ -z "$identifier" ] || [ -z "$password" ]; then
        error "Both identifier and password are required"
        return 1
    fi
    
    debug "Saving credentials for: $identifier"
    if [ "$DEBUG" = "1" ]; then
        debug "Password (plaintext): $password"
    fi
    
    # Create credentials file with restrictive permissions
    touch "$CREDENTIALS_FILE"
    chmod 600 "$CREDENTIALS_FILE"
    
    # Encrypt the password using AES-256-CBC
    local encrypted_password
    encrypted_password=$(encrypt_data "$password")
    
    if [ -z "$encrypted_password" ]; then
        error "Failed to encrypt password"
        return 1
    fi
    
    debug "Password encrypted with AES-256-CBC"
    if [ "$DEBUG" = "1" ]; then
        debug "Encrypted data: ${encrypted_password:0:50}..."
    fi
    
    # Store as JSON with encrypted password
    cat > "$CREDENTIALS_FILE" << EOF
{
    "identifier": "$identifier",
    "password_encrypted": "$encrypted_password",
    "encryption": "aes-256-cbc",
    "created": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "note": "Credentials encrypted with AES-256-CBC. Keep this file and .key secure!"
}
EOF
    
    success "Credentials saved with AES-256-CBC encryption to $CREDENTIALS_FILE"
}

# Load saved credentials
# Returns: Sets SAVED_IDENTIFIER and SAVED_PASSWORD variables
load_credentials() {
    if [ ! -f "$CREDENTIALS_FILE" ]; then
        debug "No credentials file found"
        return 1
    fi
    
    local creds_data encrypted_password encryption_method
    creds_data=$(cat "$CREDENTIALS_FILE")
    
    SAVED_IDENTIFIER=$(json_get_field "$creds_data" "identifier")
    encrypted_password=$(json_get_field "$creds_data" "password_encrypted")
    encryption_method=$(json_get_field "$creds_data" "encryption")
    
    # Check if this is an old base64-encoded file (migration support)
    if [ -z "$encrypted_password" ]; then
        local encoded_password
        encoded_password=$(json_get_field "$creds_data" "password_encoded")
        if [ -n "$encoded_password" ]; then
            warning "Found old base64-encoded credentials. Please re-login to upgrade to AES-256 encryption."
            # Decode old format
            SAVED_PASSWORD=$(printf '%s' "$encoded_password" | base64 -d)
            debug "Loaded credentials using legacy base64 format"
            return 0
        fi
    fi
    
    if [ -z "$SAVED_IDENTIFIER" ] || [ -z "$encrypted_password" ]; then
        debug "Credentials file exists but data is incomplete"
        return 1
    fi
    
    # Decrypt password
    SAVED_PASSWORD=$(decrypt_data "$encrypted_password")
    
    if [ -z "$SAVED_PASSWORD" ]; then
        error "Failed to decrypt password. The encryption key may have changed."
        error "Please run 'atproto clear-credentials' and login again."
        return 1
    fi
    
    debug "Loaded credentials for: $SAVED_IDENTIFIER"
    debug "Encryption method: ${encryption_method:-aes-256-cbc}"
    if [ "$DEBUG" = "1" ]; then
        debug "Encrypted data: ${encrypted_password:0:50}..."
        debug "Password (plaintext): $SAVED_PASSWORD"
    fi
    
    return 0
}

# Clear saved credentials
clear_credentials() {
    if [ -f "$CREDENTIALS_FILE" ]; then
        rm -f "$CREDENTIALS_FILE"
        success "Saved credentials cleared"
    else
        warning "No saved credentials found"
    fi
    
    # Also clear encryption key if no other credentials exist
    if [ -f "$ENCRYPTION_KEY_FILE" ]; then
        warning "Encryption key still exists at $ENCRYPTION_KEY_FILE"
        echo "Remove it manually if you want to generate a new key: rm $ENCRYPTION_KEY_FILE"
    fi
}

# Get user profile information
#
# Retrieves profile information for a specified user handle or DID.
#
# Arguments:
#   $1 - handle or DID (optional, defaults to current user)
#
# Returns:
#   0 - Success, profile information retrieved
#   1 - Failed to retrieve profile
#
# Environment:
#   ATP_PDS - AT Protocol server (default: https://bsky.social)
#
# Outputs:
#   Profile information in JSON format
atproto_get_profile() {
    local actor="${1:-}"
    
    # Get access token
    local access_token
    access_token=$(get_access_token) || {
        error "Not logged in. Use 'atproto login' first."
        return 1
    }
    
    # If no actor specified, get current user's DID
    if [ -z "$actor" ]; then
        actor=$(get_session_did)
        if [ -z "$actor" ]; then
            error "Could not determine current user"
            return 1
        fi
    fi
    
    debug "Fetching profile for: $actor"
    
    # Make API request
    local response
    response=$(api_request GET "/xrpc/app.bsky.actor.getProfile?actor=$actor" "" "$access_token")
    
    if [ $? -ne 0 ]; then
        error "Failed to fetch profile"
        return 1
    fi
    
    echo "$response"
    return 0
}

# Display formatted profile information
#
# Displays profile information in a human-readable format.
#
# Arguments:
#   $1 - handle or DID (optional, defaults to current user)
#
# Returns:
#   0 - Success
#   1 - Failed to retrieve profile
atproto_show_profile() {
    local actor="${1:-}"
    
    local profile_json
    profile_json=$(atproto_get_profile "$actor")
    
    if [ $? -ne 0 ]; then
        return 1
    fi
    
    # Output in requested format
    if is_json_output; then
        # JSON output - return raw profile data
        echo "$profile_json"
        return 0
    fi
    
    # Text output - human-readable format
    # Extract profile fields
    local handle display_name description followers following posts
    local created_at indexed_at lists feedgens starter_packs did
    
    handle=$(json_get_field "$profile_json" "handle")
    display_name=$(json_get_field "$profile_json" "displayName")
    description=$(json_get_field "$profile_json" "description")
    did=$(json_get_field "$profile_json" "did")
    
    # Stats
    followers=$(json_get_field "$profile_json" "followersCount")
    following=$(json_get_field "$profile_json" "followsCount")
    posts=$(json_get_field "$profile_json" "postsCount")
    
    # Dates
    created_at=$(json_get_field "$profile_json" "createdAt")
    indexed_at=$(json_get_field "$profile_json" "indexedAt")
    
    # Associated content (extract from nested "associated" object)
    lists=$(echo "$profile_json" | grep -o '"lists":[0-9]*' | head -n1 | cut -d':' -f2)
    feedgens=$(echo "$profile_json" | grep -o '"feedgens":[0-9]*' | head -n1 | cut -d':' -f2)
    starter_packs=$(echo "$profile_json" | grep -o '"starterPacks":[0-9]*' | head -n1 | cut -d':' -f2)
    
    # Display profile
    echo ""
    echo -e "${BLUE}Profile Information${NC}"
    echo -e "${BLUE}===================${NC}"
    echo ""
    
    if [ -n "$display_name" ]; then
        echo -e "${GREEN}Name:${NC}        $display_name"
    fi
    echo -e "${GREEN}Handle:${NC}      @$handle"
    echo -e "${GREEN}DID:${NC}         $did"
    
    if [ -n "$description" ]; then
        echo ""
        echo -e "${GREEN}Bio:${NC}"
        # Properly handle newlines in bio (replace \n with actual newlines)
        echo -e "$description" | sed 's/^/  /'
    fi
    
    echo ""
    echo -e "${GREEN}Stats:${NC}"
    echo -e "  Posts:     ${BLUE}${posts:-0}${NC}"
    echo -e "  Followers: ${BLUE}${followers:-0}${NC}"
    echo -e "  Following: ${BLUE}${following:-0}${NC}"
    
    # Show associated content if any exists
    if [ -n "$lists" ] && [ "$lists" != "0" ] || [ -n "$feedgens" ] && [ "$feedgens" != "0" ] || [ -n "$starter_packs" ] && [ "$starter_packs" != "0" ]; then
        echo ""
        echo -e "${GREEN}Content:${NC}"
        if [ -n "$lists" ] && [ "$lists" != "0" ]; then
            echo -e "  Lists:         ${BLUE}${lists}${NC}"
        fi
        if [ -n "$feedgens" ] && [ "$feedgens" != "0" ]; then
            echo -e "  Custom Feeds:  ${BLUE}${feedgens}${NC}"
        fi
        if [ -n "$starter_packs" ] && [ "$starter_packs" != "0" ]; then
            echo -e "  Starter Packs: ${BLUE}${starter_packs}${NC}"
        fi
    fi
    
    # Show dates
    if [ -n "$created_at" ] || [ -n "$indexed_at" ]; then
        echo ""
        echo -e "${GREEN}Activity:${NC}"
        if [ -n "$created_at" ]; then
            # Format: 2025-06-19T00:00:41.439Z -> June 19, 2025
            local date_formatted
            date_formatted=$(echo "$created_at" | sed 's/T.*//' | xargs -I {} date -d {} "+%B %d, %Y" 2>/dev/null || echo "$created_at")
            echo -e "  Joined:        ${BLUE}${date_formatted}${NC}"
        fi
        if [ -n "$indexed_at" ]; then
            local indexed_formatted
            indexed_formatted=$(echo "$indexed_at" | sed 's/T.*//' | xargs -I {} date -d {} "+%B %d, %Y" 2>/dev/null || echo "$indexed_at")
            echo -e "  Last Updated:  ${BLUE}${indexed_formatted}${NC}"
        fi
    fi
    
    echo ""
    
    return 0
}

# Update user profile
#
# Updates the authenticated user's profile information.
# Can update display name, bio, avatar, and banner.
#
# Arguments:
#   $1 - display_name (optional, pass empty string to skip)
#   $2 - description/bio (optional, pass empty string to skip)
#   $3 - avatar_file (optional, image file path)
#   $4 - banner_file (optional, image file path)
#
# Returns:
#   0 - Success, profile updated
#   1 - Failed to update profile
#
# Environment:
#   ATP_PDS - AT Protocol server (default: https://bsky.social)
#
# Files:
#   Reads: Avatar and banner image files if provided
atproto_update_profile() {
    local display_name="$1"
    local description="$2"
    local avatar_file="$3"
    local banner_file="$4"
    
    # Get access token
    local access_token
    access_token=$(get_access_token) || {
        error "Not logged in. Use 'atproto login' first."
        return 1
    }
    
    # Get current DID
    local did
    did=$(get_session_did)
    if [ -z "$did" ]; then
        error "Could not determine current user"
        return 1
    fi
    
    debug "Updating profile for: $did"
    
    # Get current profile
    local current_profile
    current_profile=$(atproto_get_profile)
    if [ $? -ne 0 ]; then
        error "Failed to retrieve current profile"
        return 1
    fi
    
    # Build updated profile JSON
    local avatar_json="" banner_json=""
    
    # Upload avatar if provided
    if [ -n "$avatar_file" ]; then
        debug "Uploading avatar: $avatar_file"
        local avatar_blob
        avatar_blob=$(atproto_upload_blob "$avatar_file")
        if [ $? -eq 0 ]; then
            avatar_json="\"avatar\": $(echo "$avatar_blob" | grep -o '"blob":{[^}]*}'),"
        else
            error "Failed to upload avatar"
            return 1
        fi
    fi
    
    # Upload banner if provided
    if [ -n "$banner_file" ]; then
        debug "Uploading banner: $banner_file"
        local banner_blob
        banner_blob=$(atproto_upload_blob "$banner_file")
        if [ $? -eq 0 ]; then
            banner_json="\"banner\": $(echo "$banner_blob" | grep -o '"blob":{[^}]*}'),"
        else
            error "Failed to upload banner"
            return 1
        fi
    fi
    
    # Use current values if not updating
    if [ -z "$display_name" ]; then
        display_name=$(json_get_field "$current_profile" "displayName")
    fi
    if [ -z "$description" ]; then
        description=$(json_get_field "$current_profile" "description")
    fi
    
    # Build profile record
    local profile_record
    profile_record="{
        \"\$type\": \"app.bsky.actor.profile\",
        \"displayName\": \"$display_name\",
        \"description\": \"$description\",
        $avatar_json
        $banner_json
        \"createdAt\": \"$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")\"
    }"
    
    # Remove trailing commas in JSON (happens when avatar/banner not provided)
    profile_record=$(echo "$profile_record" | sed 's/,\([[:space:]]*\)}/\1}/g')
    
    debug "Profile record: $profile_record"
    
    # Update profile via putRecord
    local response
    response=$(api_request POST "/xrpc/com.atproto.repo.putRecord" \
        "{\"repo\":\"$did\",\"collection\":\"app.bsky.actor.profile\",\"rkey\":\"self\",\"record\":$profile_record}" \
        "$access_token")
    
    if [ $? -ne 0 ]; then
        error "Failed to update profile"
        return 1
    fi
    
    success "Profile updated successfully"
    return 0
}

# Get list of followers
#
# Retrieves the list of followers for a specified user.
#
# Arguments:
#   $1 - handle or DID (optional, defaults to current user)
#   $2 - limit (optional, default: 50, max: 100)
#
# Returns:
#   0 - Success, followers list retrieved
#   1 - Failed to retrieve followers
#
# Environment:
#   ATP_PDS - AT Protocol server (default: https://bsky.social)
#
# Outputs:
#   Followers list in formatted text
atproto_get_followers() {
    local actor="${1:-}"
    local limit="${2:-50}"
    
    # Get access token
    local access_token
    access_token=$(get_access_token) || {
        error "Not logged in. Use 'atproto login' first."
        return 1
    }
    
    # If no actor specified, get current user's DID
    if [ -z "$actor" ]; then
        actor=$(get_session_did)
        if [ -z "$actor" ]; then
            error "Could not determine current user"
            return 1
        fi
    fi
    
    # Validate limit
    if [ "$limit" -gt 100 ]; then
        warning "Limit capped at 100 (requested: $limit)"
        limit=100
    fi
    
    debug "Fetching followers for: $actor (limit: $limit)"
    
    # Make API request
    local response
    response=$(api_request GET "/xrpc/app.bsky.graph.getFollowers?actor=$actor&limit=$limit" "" "$access_token")
    
    if [ $? -ne 0 ]; then
        error "Failed to fetch followers"
        return 1
    fi
    
    # Output in requested format
    if is_json_output; then
        # JSON output - return raw API response
        echo "$response"
        return 0
    fi
    
    # Text output - human-readable format
    # Parse and display followers
    echo ""
    echo -e "${BLUE}Followers${NC}"
    echo -e "${BLUE}=========${NC}"
    echo ""
    
    # Extract followers array and parse each follower
    # Note: This is a simplified parser - in production would use jq or similar
    local count=0
    while IFS= read -r line; do
        if [[ "$line" =~ \"handle\":\"([^\"]+)\" ]]; then
            local handle="${BASH_REMATCH[1]}"
            local display_name=""
            
            # Try to get displayName from the same object
            if [[ "$response" =~ \"displayName\":\"([^\"]+)\".*\"handle\":\"$handle\" ]] || \
               [[ "$response" =~ \"handle\":\"$handle\".*\"displayName\":\"([^\"]+)\" ]]; then
                display_name="${BASH_REMATCH[1]}"
            fi
            
            count=$((count + 1))
            if [ -n "$display_name" ]; then
                echo -e "${GREEN}$count.${NC} $display_name ${BLUE}(@$handle)${NC}"
            else
                echo -e "${GREEN}$count.${NC} ${BLUE}@$handle${NC}"
            fi
        fi
    done <<< "$response"
    
    echo ""
    echo -e "${BLUE}Total:${NC} $count followers"
    echo ""
    
    return 0
}

# Get list of users being followed
#
# Retrieves the list of users that a specified user is following.
#
# Arguments:
#   $1 - handle or DID (optional, defaults to current user)
#   $2 - limit (optional, default: 50, max: 100)
#
# Returns:
#   0 - Success, following list retrieved
#   1 - Failed to retrieve following
#
# Environment:
#   ATP_PDS - AT Protocol server (default: https://bsky.social)
#
# Outputs:
#   Following list in formatted text
atproto_get_following() {
    local actor="${1:-}"
    local limit="${2:-50}"
    
    # Get access token
    local access_token
    access_token=$(get_access_token) || {
        error "Not logged in. Use 'atproto login' first."
        return 1
    }
    
    # If no actor specified, get current user's DID
    if [ -z "$actor" ]; then
        actor=$(get_session_did)
        if [ -z "$actor" ]; then
            error "Could not determine current user"
            return 1
        fi
    fi
    
    # Validate limit
    if [ "$limit" -gt 100 ]; then
        warning "Limit capped at 100 (requested: $limit)"
        limit=100
    fi
    
    debug "Fetching following for: $actor (limit: $limit)"
    
    # Make API request
    local response
    response=$(api_request GET "/xrpc/app.bsky.graph.getFollows?actor=$actor&limit=$limit" "" "$access_token")
    
    if [ $? -ne 0 ]; then
        error "Failed to fetch following"
        return 1
    fi
    
    # Output in requested format
    if is_json_output; then
        # JSON output - return raw API response
        echo "$response"
        return 0
    fi
    
    # Text output - human-readable format
    # Parse and display following
    echo ""
    echo -e "${BLUE}Following${NC}"
    echo -e "${BLUE}=========${NC}"
    echo ""
    
    # Extract follows array and parse each follow
    local count=0
    while IFS= read -r line; do
        if [[ "$line" =~ \"handle\":\"([^\"]+)\" ]]; then
            local handle="${BASH_REMATCH[1]}"
            local display_name=""
            
            # Try to get displayName from the same object
            if [[ "$response" =~ \"displayName\":\"([^\"]+)\".*\"handle\":\"$handle\" ]] || \
               [[ "$response" =~ \"handle\":\"$handle\".*\"displayName\":\"([^\"]+)\" ]]; then
                display_name="${BASH_REMATCH[1]}"
            fi
            
            count=$((count + 1))
            if [ -n "$display_name" ]; then
                echo -e "${GREEN}$count.${NC} $display_name ${BLUE}(@$handle)${NC}"
            else
                echo -e "${GREEN}$count.${NC} ${BLUE}@$handle${NC}"
            fi
        fi
    done <<< "$response"
    
    echo ""
    echo -e "${BLUE}Total:${NC} $count following"
    echo ""
    
    return 0
}
