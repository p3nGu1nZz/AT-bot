#!/bin/bash
# Interactive Mode Support for atproto
# Provides user-friendly prompts for complex operations

# Source reporter library for console display functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/reporter.sh" ]; then
    source "$SCRIPT_DIR/reporter.sh"
else
    echo "Error: reporter.sh not found in $SCRIPT_DIR" >&2
    exit 1
fi

# Source validation library
if [ -f "$SCRIPT_DIR/validation.sh" ]; then
    source "$SCRIPT_DIR/validation.sh"
fi

# Check if we're in interactive mode
is_interactive() {
    [ "${ATP_INTERACTIVE:-0}" = "1" ]
}

# Prompt user for input with validation
#
# Arguments:
#   $1 - Prompt message
#   $2 - Validation function name (optional)
#   $3 - Default value (optional)
#
# Returns:
#   0 - Success, value printed to stdout
#   1 - Validation failed or user cancelled
#
# Example:
#   text=$(prompt_input "Enter post text:" "validate_post_text")
prompt_input() {
    local prompt_msg="$1"
    local validator="${2:-}"
    local default="${3:-}"
    
    # Show default if provided
    if [ -n "$default" ]; then
        prompt_msg="$prompt_msg [$default]"
    fi
    
    local input
    while true; do
        # Read input
        read -r -p "$(echo -e "${CYAN}${prompt_msg}${NC} ")" input
        
        # Use default if no input provided
        if [ -z "$input" ] && [ -n "$default" ]; then
            input="$default"
        fi
        
        # Validate if validator provided
        if [ -n "$validator" ] && type "$validator" &>/dev/null; then
            if $validator "$input"; then
                echo "$input"
                return 0
            else
                warning "Invalid input. Please try again."
                continue
            fi
        else
            # No validator, just return input
            echo "$input"
            return 0
        fi
    done
}

# Prompt for password (hidden input)
#
# Arguments:
#   $1 - Prompt message
#
# Returns:
#   0 - Success, value printed to stdout
#   1 - Failed
prompt_password() {
    local prompt_msg="$1"
    local input
    
    read -r -s -p "$(echo -e "${CYAN}${prompt_msg}${NC} ")" input
    echo >&2  # New line after hidden input
    
    echo "$input"
    return 0
}

# Prompt user for confirmation (yes/no)
#
# Arguments:
#   $1 - Confirmation message
#   $2 - Default value (y/n, optional)
#
# Returns:
#   0 - User confirmed (yes)
#   1 - User declined (no)
#
# Example:
#   if prompt_confirm "Delete this post?"; then
#       delete_post
#   fi
prompt_confirm() {
    local message="$1"
    local default="${2:-n}"
    
    local prompt_suffix
    if [ "$default" = "y" ]; then
        prompt_suffix="[Y/n]"
    else
        prompt_suffix="[y/N]"
    fi
    
    local response
    read -r -p "$(echo -e "${YELLOW}${message}${NC} $prompt_suffix ")" response
    
    # Use default if no response
    if [ -z "$response" ]; then
        response="$default"
    fi
    
    # Check response
    case "$response" in
        [yY]|[yY][eE][sS])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Prompt user to select from a list of options
#
# Arguments:
#   $1 - Prompt message
#   $@ - Options (remaining arguments)
#
# Returns:
#   0 - Success, selected option printed to stdout
#   1 - Invalid selection or cancelled
#
# Example:
#   choice=$(prompt_select "Choose format:" "text" "json" "xml")
prompt_select() {
    local prompt_msg="$1"
    shift
    local options=("$@")
    
    if [ ${#options[@]} -eq 0 ]; then
        error "No options provided"
        return 1
    fi
    
    # Display options
    echo ""
    echo -e "${CYAN}${prompt_msg}${NC}"
    for i in "${!options[@]}"; do
        printf "  %d) %s\n" $((i + 1)) "${options[$i]}"
    done
    echo ""
    
    # Get selection
    local selection
    while true; do
        read -r -p "$(echo -e "${CYAN}Select option (1-${#options[@]}):${NC} ")" selection
        
        # Validate selection
        if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le "${#options[@]}" ]; then
            echo "${options[$((selection - 1))]}"
            return 0
        else
            warning "Invalid selection. Please enter a number between 1 and ${#options[@]}."
        fi
    done
}

# Interactive post creation
#
# Prompts user for post content and optional media attachments.
#
# Returns:
#   0 - Success, post created
#   1 - Failed or cancelled
interactive_post() {
    echo ""
    info "=== Interactive Post Creation ==="
    echo ""
    
    # Get post text
    local post_text
    post_text=$(prompt_input "Enter post text:" "validate_post_text") || return 1
    
    if [ -z "$post_text" ]; then
        error "Post text cannot be empty"
        return 1
    fi
    
    # Ask about image attachment
    if prompt_confirm "Attach an image?" "n"; then
        local image_path
        image_path=$(prompt_input "Enter image path:") || return 1
        
        if [ ! -f "$image_path" ]; then
            error "Image file not found: $image_path"
            return 1
        fi
        
        if ! validate_image_file "$image_path"; then
            error "Invalid image file"
            return 1
        fi
        
        # Create post with image
        info "Creating post with image..."
        atproto_post "$post_text" --image "$image_path"
    else
        # Create text-only post
        info "Creating post..."
        atproto_post "$post_text"
    fi
    
    return $?
}

# Interactive reply creation
#
# Prompts user for post URI and reply content.
#
# Returns:
#   0 - Success, reply created
#   1 - Failed or cancelled
interactive_reply() {
    echo ""
    info "=== Interactive Reply Creation ==="
    echo ""
    
    # Get post URI
    local post_uri
    post_uri=$(prompt_input "Enter post URI to reply to:" "validate_at_uri") || return 1
    
    if [ -z "$post_uri" ]; then
        error "Post URI cannot be empty"
        return 1
    fi
    
    # Get reply text
    local reply_text
    reply_text=$(prompt_input "Enter reply text:" "validate_post_text") || return 1
    
    if [ -z "$reply_text" ]; then
        error "Reply text cannot be empty"
        return 1
    fi
    
    # Confirm
    if prompt_confirm "Send reply?" "y"; then
        info "Sending reply..."
        atproto_reply "$post_uri" "$reply_text"
        return $?
    else
        info "Reply cancelled"
        return 1
    fi
}

# Interactive profile edit
#
# Prompts user for profile fields to update.
#
# Returns:
#   0 - Success, profile updated
#   1 - Failed or cancelled
interactive_profile_edit() {
    echo ""
    info "=== Interactive Profile Editor ==="
    echo ""
    
    info "Press Enter to keep current value, or type new value to update."
    echo ""
    
    # Get current profile
    local current_profile
    current_profile=$(atproto_show_profile --json 2>/dev/null) || {
        error "Failed to fetch current profile"
        return 1
    }
    
    # Extract current values
    local current_name
    local current_bio
    current_name=$(echo "$current_profile" | python3 -c "import sys, json; print(json.load(sys.stdin).get('displayName', ''))" 2>/dev/null || echo "")
    current_bio=$(echo "$current_profile" | python3 -c "import sys, json; print(json.load(sys.stdin).get('description', ''))" 2>/dev/null || echo "")
    
    # Prompt for new values
    local new_name
    local new_bio
    local avatar_path
    local banner_path
    
    new_name=$(prompt_input "Display name:" "" "$current_name") || return 1
    new_bio=$(prompt_input "Bio:" "" "$current_bio") || return 1
    
    # Ask about avatar
    local update_avatar=0
    if prompt_confirm "Update avatar?" "n"; then
        avatar_path=$(prompt_input "Avatar image path:") || return 1
        if [ -n "$avatar_path" ] && [ -f "$avatar_path" ]; then
            update_avatar=1
        fi
    fi
    
    # Ask about banner
    local update_banner=0
    if prompt_confirm "Update banner?" "n"; then
        banner_path=$(prompt_input "Banner image path:") || return 1
        if [ -n "$banner_path" ] && [ -f "$banner_path" ]; then
            update_banner=1
        fi
    fi
    
    # Confirm changes
    echo ""
    info "Profile changes:"
    if [ -n "$new_name" ] && [ "$new_name" != "$current_name" ]; then
        echo "  Display name: $new_name"
    fi
    if [ -n "$new_bio" ] && [ "$new_bio" != "$current_bio" ]; then
        echo "  Bio: $new_bio"
    fi
    if [ $update_avatar -eq 1 ]; then
        echo "  Avatar: $avatar_path"
    fi
    if [ $update_banner -eq 1 ]; then
        echo "  Banner: $banner_path"
    fi
    echo ""
    
    if prompt_confirm "Apply changes?" "y"; then
        info "Updating profile..."
        
        # Build command
        local cmd="atproto_edit_profile"
        [ -n "$new_name" ] && cmd="$cmd --name \"$new_name\""
        [ -n "$new_bio" ] && cmd="$cmd --bio \"$new_bio\""
        [ $update_avatar -eq 1 ] && cmd="$cmd --avatar \"$avatar_path\""
        [ $update_banner -eq 1 ] && cmd="$cmd --banner \"$banner_path\""
        
        eval "$cmd"
        return $?
    else
        info "Profile update cancelled"
        return 1
    fi
}

# Interactive mode main menu
#
# Displays menu of available operations and handles user selection.
#
# Returns:
#   0 - Success
#   1 - Failed or user quit
interactive_menu() {
    while true; do
        echo ""
        echo "================================"
        info "   atproto Interactive Mode"
        echo "================================"
        echo ""
        
        local choice
        choice=$(prompt_select "What would you like to do?" \
            "Create a post" \
            "Reply to a post" \
            "View timeline" \
            "Search posts" \
            "View profile" \
            "Edit profile" \
            "Manage follows" \
            "Exit interactive mode") || return 1
        
        case "$choice" in
            "Create a post")
                interactive_post
                ;;
            "Reply to a post")
                interactive_reply
                ;;
            "View timeline")
                local limit
                limit=$(prompt_input "Number of posts:" "validate_limit" "10") || continue
                atproto_feed "" "$limit"
                ;;
            "Search posts")
                local query
                query=$(prompt_input "Search query:") || continue
                local limit
                limit=$(prompt_input "Number of results:" "validate_limit" "10") || continue
                atproto_search "$query" "$limit"
                ;;
            "View profile")
                local handle
                handle=$(prompt_input "Handle (press Enter for your profile):") || continue
                atproto_show_profile "$handle"
                ;;
            "Edit profile")
                interactive_profile_edit
                ;;
            "Manage follows")
                local action
                action=$(prompt_select "Follow action:" "Follow user" "Unfollow user" "View followers" "View following" "Cancel") || continue
                
                case "$action" in
                    "Follow user")
                        local user
                        user=$(prompt_input "User handle:" "validate_handle") || continue
                        atproto_follow "$user"
                        ;;
                    "Unfollow user")
                        local user
                        user=$(prompt_input "User handle:" "validate_handle") || continue
                        atproto_unfollow "$user"
                        ;;
                    "View followers")
                        local handle
                        handle=$(prompt_input "Handle (press Enter for your followers):") || continue
                        atproto_get_followers "$handle"
                        ;;
                    "View following")
                        local handle
                        handle=$(prompt_input "Handle (press Enter for your following):") || continue
                        atproto_get_following "$handle"
                        ;;
                esac
                ;;
            "Exit interactive mode")
                info "Exiting interactive mode"
                return 0
                ;;
        esac
        
        # Pause before showing menu again
        echo ""
        read -r -p "Press Enter to continue..."
    done
}
