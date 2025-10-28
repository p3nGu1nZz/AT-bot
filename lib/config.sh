#!/bin/bash
# AT-bot Configuration Management
# Handles user preferences and configuration persistence

# Source reporter library for console display functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/reporter.sh" ]; then
    source "$SCRIPT_DIR/reporter.sh"
else
    echo "Error: reporter.sh not found in $SCRIPT_DIR" >&2
    exit 1
fi

# Configuration file location
CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/at-bot/config.json"

# Default configuration values
DEFAULT_PDS="https://bsky.social"
DEFAULT_OUTPUT_FORMAT="text"
DEFAULT_COLOR_OUTPUT="auto"
DEFAULT_FEED_LIMIT="20"
DEFAULT_SEARCH_LIMIT="10"
DEFAULT_DEBUG="false"

# Initialize configuration system
# Creates config file with defaults if it doesn't exist
#
# Returns:
#   0 - Success
#   1 - Failed to create config directory or file
init_config() {
    local config_dir
    config_dir="$(dirname "$CONFIG_FILE")"
    
    # Create config directory if needed
    if [ ! -d "$config_dir" ]; then
        if ! mkdir -p "$config_dir" 2>/dev/null; then
            error "Failed to create config directory: $config_dir"
            return 1
        fi
    fi
    
    # Create default config if doesn't exist
    if [ ! -f "$CONFIG_FILE" ]; then
        if ! create_default_config; then
            error "Failed to create default configuration"
            return 1
        fi
    fi
    
    # Ensure proper permissions
    chmod 644 "$CONFIG_FILE" 2>/dev/null || true
    
    return 0
}

# Create default configuration file
#
# Returns:
#   0 - Success
#   1 - Failed to write config
create_default_config() {
    cat > "$CONFIG_FILE" << EOF
{
  "pds_endpoint": "$DEFAULT_PDS",
  "output_format": "$DEFAULT_OUTPUT_FORMAT",
  "color_output": "$DEFAULT_COLOR_OUTPUT",
  "feed_limit": $DEFAULT_FEED_LIMIT,
  "search_limit": $DEFAULT_SEARCH_LIMIT,
  "debug": $DEFAULT_DEBUG
}
EOF
    
    if [ $? -ne 0 ]; then
        return 1
    fi
    
    return 0
}

# Get a configuration value
#
# Arguments:
#   $1 - Configuration key
#
# Returns:
#   0 - Success, value printed to stdout
#   1 - Key not found or invalid
#
# Example:
#   pds=$(get_config "pds_endpoint")
get_config() {
    local key="$1"
    
    if [ -z "$key" ]; then
        error "Configuration key required"
        return 1
    fi
    
    # Initialize config if needed
    init_config || return 1
    
    # Extract value using grep and sed - preserve URLs properly
    local value
    value=$(grep "\"$key\"" "$CONFIG_FILE" 2>/dev/null | sed 's/^[[:space:]]*"[^"]*"[[:space:]]*:[[:space:]]*"\?\([^"]*\)"\?[,}].*$/\1/')
    
    if [ -z "$value" ]; then
        # Return default value for known keys
        case "$key" in
            pds_endpoint)   echo "$DEFAULT_PDS" ;;
            output_format)  echo "$DEFAULT_OUTPUT_FORMAT" ;;
            color_output)   echo "$DEFAULT_COLOR_OUTPUT" ;;
            feed_limit)     echo "$DEFAULT_FEED_LIMIT" ;;
            search_limit)   echo "$DEFAULT_SEARCH_LIMIT" ;;
            debug)          echo "$DEFAULT_DEBUG" ;;
            *)
                error "Unknown configuration key: $key"
                return 1
                ;;
        esac
    else
        echo "$value"
    fi
    
    return 0
}

# Set a configuration value
#
# Arguments:
#   $1 - Configuration key
#   $2 - Configuration value
#
# Returns:
#   0 - Success
#   1 - Invalid key or value, or failed to update
#
# Example:
#   set_config "feed_limit" "50"
set_config() {
    local key="$1"
    local value="$2"
    
    if [ -z "$key" ] || [ -z "$value" ]; then
        error "Both key and value required"
        return 1
    fi
    
    # Initialize config if needed
    init_config || return 1
    
    # Validate key
    case "$key" in
        pds_endpoint)
            # Validate URL format
            if ! echo "$value" | grep -qE '^https?://'; then
                error "Invalid PDS endpoint: must start with http:// or https://"
                return 1
            fi
            ;;
        output_format)
            # Validate format
            if [ "$value" != "text" ] && [ "$value" != "json" ]; then
                error "Invalid output format: must be 'text' or 'json'"
                return 1
            fi
            ;;
        color_output)
            # Validate color option
            if [ "$value" != "auto" ] && [ "$value" != "always" ] && [ "$value" != "never" ]; then
                error "Invalid color option: must be 'auto', 'always', or 'never'"
                return 1
            fi
            ;;
        feed_limit|search_limit)
            # Validate numeric
            if ! echo "$value" | grep -qE '^[0-9]+$'; then
                error "Invalid limit: must be a positive number"
                return 1
            fi
            if [ "$value" -lt 1 ] || [ "$value" -gt 100 ]; then
                error "Invalid limit: must be between 1 and 100"
                return 1
            fi
            ;;
        debug)
            # Validate boolean
            if [ "$value" != "true" ] && [ "$value" != "false" ]; then
                error "Invalid debug value: must be 'true' or 'false'"
                return 1
            fi
            ;;
        *)
            error "Unknown configuration key: $key"
            return 1
            ;;
    esac
    
    # Update the configuration file
    local temp_file
    temp_file="${CONFIG_FILE}.tmp"
    
    # Determine if value should be quoted
    local quoted_value
    case "$key" in
        feed_limit|search_limit)
            quoted_value="$value"  # Numbers unquoted
            ;;
        debug)
            quoted_value="$value"  # Booleans unquoted
            ;;
        *)
            quoted_value="\"$value\""  # Strings quoted
            ;;
    esac
    
    # Replace the value
    if grep -q "\"$key\"" "$CONFIG_FILE"; then
        # Key exists, update it
        sed "s|\"$key\": *[^,]*|\"$key\": $quoted_value|" "$CONFIG_FILE" > "$temp_file"
    else
        # Key doesn't exist, add it (before closing brace)
        sed "s|}|  \"$key\": $quoted_value\n}|" "$CONFIG_FILE" > "$temp_file"
    fi
    
    # Replace original file
    if [ -f "$temp_file" ]; then
        mv "$temp_file" "$CONFIG_FILE"
        success "Configuration updated: $key = $value"
        return 0
    else
        error "Failed to update configuration"
        return 1
    fi
}

# List all configuration values
#
# Returns:
#   0 - Success
list_config() {
    # Initialize config if needed
    init_config || return 1
    
    echo "Current Configuration:"
    echo "====================="
    echo ""
    
    echo "PDS Endpoint:    $(get_config pds_endpoint)"
    echo "Output Format:   $(get_config output_format)"
    echo "Color Output:    $(get_config color_output)"
    echo "Feed Limit:      $(get_config feed_limit)"
    echo "Search Limit:    $(get_config search_limit)"
    echo "Debug Mode:      $(get_config debug)"
    echo ""
    echo "Config file: $CONFIG_FILE"
    
    return 0
}

# Reset configuration to defaults
#
# Returns:
#   0 - Success
#   1 - Failed to reset
reset_config() {
    warning "This will reset all configuration to defaults"
    
    # Backup existing config
    if [ -f "$CONFIG_FILE" ]; then
        local backup_file="${CONFIG_FILE}.backup"
        cp "$CONFIG_FILE" "$backup_file"
        echo "Backup created: $backup_file"
    fi
    
    # Create new default config
    if create_default_config; then
        success "Configuration reset to defaults"
        list_config
        return 0
    else
        error "Failed to reset configuration"
        return 1
    fi
}

# Validate entire configuration file
#
# Returns:
#   0 - Configuration is valid
#   1 - Configuration has errors
validate_config() {
    # Initialize config if needed
    init_config || return 1
    
    local has_errors=0
    
    # Check if file exists and is readable
    if [ ! -f "$CONFIG_FILE" ] || [ ! -r "$CONFIG_FILE" ]; then
        error "Configuration file not found or not readable"
        return 1
    fi
    
    # Validate JSON structure (basic check)
    if ! grep -q "^{" "$CONFIG_FILE" || ! grep -q "}$" "$CONFIG_FILE"; then
        error "Invalid JSON structure in configuration file"
        has_errors=1
    fi
    
    # Validate each field
    local keys="pds_endpoint output_format color_output feed_limit search_limit debug"
    for key in $keys; do
        local value
        value=$(get_config "$key" 2>/dev/null)
        if [ $? -ne 0 ]; then
            warning "Missing or invalid configuration: $key"
            has_errors=1
        fi
    done
    
    if [ $has_errors -eq 0 ]; then
        success "Configuration is valid"
        return 0
    else
        error "Configuration has errors. Run 'at-bot config reset' to fix."
        return 1
    fi
}

# Get effective configuration value
# This respects environment variables over config file
#
# Arguments:
#   $1 - Configuration key
#   $2 - Environment variable name (optional)
#
# Returns:
#   0 - Success, value printed to stdout
#
# Example:
#   pds=$(get_effective_config "pds_endpoint" "ATP_PDS")
get_effective_config() {
    local key="$1"
    local env_var="$2"
    
    # Check environment variable first
    if [ -n "$env_var" ] && [ -n "${!env_var}" ]; then
        echo "${!env_var}"
        return 0
    fi
    
    # Fall back to config file
    get_config "$key"
}

# Export configuration as environment variables
# Useful for scripts and automation
#
# Returns:
#   0 - Success
export_config() {
    init_config || return 1
    
    export ATP_PDS=$(get_config pds_endpoint)
    export ATP_OUTPUT_FORMAT=$(get_config output_format)
    export ATP_COLOR_OUTPUT=$(get_config color_output)
    export ATP_FEED_LIMIT=$(get_config feed_limit)
    export ATP_SEARCH_LIMIT=$(get_config search_limit)
    export ATP_DEBUG=$(get_config debug)
    
    return 0
}
