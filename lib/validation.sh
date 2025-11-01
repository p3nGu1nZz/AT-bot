#!/bin/bash
# Input Validation Library
# Provides validation functions for user inputs

# Validate post text length and content
# Arguments:
#   $1 - text to validate
# Returns:
#   0 - Valid
#   1 - Invalid
validate_post_text() {
    local text="$1"
    
    # Check if text is provided
    if [ -z "$text" ]; then
        error "Post text cannot be empty"
        return 1
    fi
    
    # Calculate byte length (UTF-8 aware)
    local byte_length
    byte_length=$(printf '%s' "$text" | wc -c | tr -d ' ')
    
    # Bluesky/AT Protocol post limit is 300 graphemes (approximately 300 characters)
    # We'll use byte count as approximation, but be generous for UTF-8
    if [ "$byte_length" -gt 3000 ]; then
        error "Post text too long: $byte_length bytes (max ~3000 bytes for 300 characters)"
        return 1
    fi
    
    return 0
}

# Validate handle format
# Arguments:
#   $1 - handle to validate (with or without @ prefix)
# Returns:
#   0 - Valid
#   1 - Invalid
validate_handle() {
    local handle="$1"
    
    # Remove @ prefix if present
    handle="${handle#@}"
    
    # Check if handle is provided
    if [ -z "$handle" ]; then
        error "Handle cannot be empty"
        return 1
    fi
    
    # Handle must contain at least one dot (domain)
    if ! echo "$handle" | grep -q '\.'; then
        error "Invalid handle format: must be like user.bsky.social"
        return 1
    fi
    
    # Validate handle format (alphanumeric, dots, hyphens)
    # Format: user.domain.tld
    if ! echo "$handle" | grep -qE '^[a-zA-Z0-9][a-zA-Z0-9.-]*[a-zA-Z0-9]$'; then
        error "Invalid handle format: $handle"
        return 1
    fi
    
    # Handle length check (max 253 characters per DNS spec)
    if [ ${#handle} -gt 253 ]; then
        error "Handle too long: ${#handle} characters (max 253)"
        return 1
    fi
    
    return 0
}

# Validate AT-URI format
# Arguments:
#   $1 - URI to validate
# Returns:
#   0 - Valid
#   1 - Invalid
validate_at_uri() {
    local uri="$1"
    
    # Check if URI is provided
    if [ -z "$uri" ]; then
        error "URI cannot be empty"
        return 1
    fi
    
    # AT-URI format: at://did:plc:xxx/collection/rkey
    if ! echo "$uri" | grep -qE '^at://did:[a-z0-9]+:[a-z0-9]+/[a-z0-9.]+/[a-zA-Z0-9]+$'; then
        error "Invalid AT-URI format: $uri"
        echo "Expected format: at://did:plc:xxx/app.bsky.feed.post/rkey" >&2
        return 1
    fi
    
    return 0
}

# Validate DID format
# Arguments:
#   $1 - DID to validate
# Returns:
#   0 - Valid
#   1 - Invalid
validate_did() {
    local did="$1"
    
    # Check if DID is provided
    if [ -z "$did" ]; then
        error "DID cannot be empty"
        return 1
    fi
    
    # DID format: did:method:identifier
    if ! echo "$did" | grep -qE '^did:[a-z0-9]+:[a-zA-Z0-9]+$'; then
        error "Invalid DID format: $did"
        echo "Expected format: did:plc:xxx or did:web:domain" >&2
        return 1
    fi
    
    return 0
}

# Validate image file for upload
# Arguments:
#   $1 - file path
# Returns:
#   0 - Valid
#   1 - Invalid
validate_image_file() {
    local filepath="$1"
    
    # Check if filepath is provided
    if [ -z "$filepath" ]; then
        error "Image file path cannot be empty"
        return 1
    fi
    
    # Check if file exists
    if [ ! -f "$filepath" ]; then
        error "Image file not found: $filepath"
        return 1
    fi
    
    # Check if file is readable
    if [ ! -r "$filepath" ]; then
        error "Image file not readable: $filepath"
        return 1
    fi
    
    # Get file extension
    local extension="${filepath##*.}"
    extension=$(echo "$extension" | tr '[:upper:]' '[:lower:]')
    
    # Validate image format
    case "$extension" in
        jpg|jpeg|png|gif|webp)
            # Valid image format
            ;;
        *)
            error "Unsupported image format: .$extension"
            echo "Supported formats: jpg, jpeg, png, gif, webp" >&2
            return 1
            ;;
    esac
    
    # Check file size (max 1MB for images per AT Protocol spec)
    local filesize
    filesize=$(stat -f%z "$filepath" 2>/dev/null || stat -c%s "$filepath" 2>/dev/null)
    
    if [ -n "$filesize" ] && [ "$filesize" -gt 1048576 ]; then
        error "Image file too large: $(( filesize / 1024 )) KB (max 1024 KB)"
        return 1
    fi
    
    return 0
}

# Validate video file for upload
# Arguments:
#   $1 - file path
# Returns:
#   0 - Valid
#   1 - Invalid
validate_video_file() {
    local filepath="$1"
    
    # Check if filepath is provided
    if [ -z "$filepath" ]; then
        error "Video file path cannot be empty"
        return 1
    fi
    
    # Check if file exists
    if [ ! -f "$filepath" ]; then
        error "Video file not found: $filepath"
        return 1
    fi
    
    # Check if file is readable
    if [ ! -r "$filepath" ]; then
        error "Video file not readable: $filepath"
        return 1
    fi
    
    # Get file extension
    local extension="${filepath##*.}"
    extension=$(echo "$extension" | tr '[:upper:]' '[:lower:]')
    
    # Validate video format
    case "$extension" in
        mp4|mov|avi|webm)
            # Valid video format
            ;;
        *)
            error "Unsupported video format: .$extension"
            echo "Supported formats: mp4, mov, avi, webm" >&2
            return 1
            ;;
    esac
    
    # Check file size (max 50MB for videos per AT Protocol spec)
    local filesize
    filesize=$(stat -f%z "$filepath" 2>/dev/null || stat -c%s "$filepath" 2>/dev/null)
    
    if [ -n "$filesize" ] && [ "$filesize" -gt 52428800 ]; then
        error "Video file too large: $(( filesize / 1024 / 1024 )) MB (max 50 MB)"
        return 1
    fi
    
    return 0
}

# Validate limit parameter (for feed, search, etc.)
# Arguments:
#   $1 - limit value
#   $2 - max allowed (optional, default 100)
# Returns:
#   0 - Valid
#   1 - Invalid
validate_limit() {
    local limit="$1"
    local max="${2:-100}"
    
    # Check if limit is provided
    if [ -z "$limit" ]; then
        # Empty limit is ok (will use default)
        return 0
    fi
    
    # Check if limit is a positive integer
    if ! echo "$limit" | grep -qE '^[0-9]+$'; then
        error "Limit must be a positive integer: $limit"
        return 1
    fi
    
    # Check if limit is within range
    if [ "$limit" -lt 1 ]; then
        error "Limit must be at least 1"
        return 1
    fi
    
    if [ "$limit" -gt "$max" ]; then
        error "Limit too large: $limit (max $max)"
        return 1
    fi
    
    return 0
}

# Validate URL format
# Arguments:
#   $1 - URL to validate
# Returns:
#   0 - Valid
#   1 - Invalid
validate_url() {
    local url="$1"
    
    # Check if URL is provided
    if [ -z "$url" ]; then
        error "URL cannot be empty"
        return 1
    fi
    
    # Basic URL validation
    if ! echo "$url" | grep -qE '^https?://[a-zA-Z0-9.-]+(/[^[:space:]]*)?$'; then
        error "Invalid URL format: $url"
        return 1
    fi
    
    return 0
}

# Validate email format (for login identifier)
# Arguments:
#   $1 - email to validate
# Returns:
#   0 - Valid
#   1 - Invalid
validate_email() {
    local email="$1"
    
    # Check if email is provided
    if [ -z "$email" ]; then
        error "Email cannot be empty"
        return 1
    fi
    
    # Basic email validation
    if ! echo "$email" | grep -qE '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'; then
        error "Invalid email format: $email"
        return 1
    fi
    
    return 0
}

# Validate identifier (handle or email)
# Arguments:
#   $1 - identifier to validate
# Returns:
#   0 - Valid
#   1 - Invalid
validate_identifier() {
    local identifier="$1"
    
    # Check if identifier is provided
    if [ -z "$identifier" ]; then
        error "Identifier cannot be empty"
        return 1
    fi
    
    # Try handle validation first
    if validate_handle "$identifier" 2>/dev/null; then
        return 0
    fi
    
    # Try email validation
    if validate_email "$identifier" 2>/dev/null; then
        return 0
    fi
    
    error "Invalid identifier format: $identifier"
    echo "Must be either a handle (user.bsky.social) or email address" >&2
    return 1
}
