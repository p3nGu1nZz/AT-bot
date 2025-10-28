#!/bin/bash
# AT-bot bash completion script
# Install with: cp scripts/at-bot-completion.bash /etc/bash_completion.d/at-bot
# Or source manually: source scripts/at-bot-completion.bash

_at_bot_completion() {
    local cur prev words cword
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    words=("${COMP_WORDS[@]}")
    cword=$COMP_CWORD

    # Main commands
    local commands=(
        "help"
        "login"
        "logout"
        "whoami"
        "post"
        "feed"
        "search"
        "follow"
        "unfollow"
        "followers"
        "following"
        "profile"
        "profile-edit"
        "like"
        "reply"
        "repost"
        "delete"
        "block"
        "unblock"
        "block-list"
    )

    # Check if we're completing a command or option
    if [[ $cword -eq 1 ]]; then
        # First argument - complete command names
        COMPREPLY=($(compgen -W "${commands[*]}" -- "$cur"))
        return 0
    fi

    # Command-specific completions
    local command="${words[1]}"
    
    case "$command" in
        login)
            # No additional completions needed
            return 0
            ;;
        logout)
            return 0
            ;;
        whoami)
            return 0
            ;;
        post)
            # post command completes file paths for --image option
            case "$prev" in
                --image)
                    COMPREPLY=($(compgen -f -- "$cur"))
                    return 0
                    ;;
                *)
                    if [[ "$cur" == -* ]]; then
                        COMPREPLY=($(compgen -W "--image --debug" -- "$cur"))
                    fi
                    return 0
                    ;;
            esac
            ;;
        feed)
            case "$prev" in
                --limit)
                    return 0
                    ;;
                *)
                    if [[ "$cur" == -* ]]; then
                        COMPREPLY=($(compgen -W "--limit --debug" -- "$cur"))
                    fi
                    return 0
                    ;;
            esac
            ;;
        search)
            case "$prev" in
                --limit)
                    return 0
                    ;;
                *)
                    if [[ "$cur" == -* ]]; then
                        COMPREPLY=($(compgen -W "--limit --debug" -- "$cur"))
                    fi
                    return 0
                    ;;
            esac
            ;;
        follow|unfollow|block|unblock)
            # These take a handle as argument
            if [[ "$cur" == -* ]]; then
                COMPREPLY=($(compgen -W "--debug" -- "$cur"))
            fi
            return 0
            ;;
        profile)
            case "$prev" in
                "profile")
                    if [[ "$cur" == -* ]]; then
                        COMPREPLY=($(compgen -W "--debug" -- "$cur"))
                    fi
                    ;;
            esac
            return 0
            ;;
        reply)
            case "$prev" in
                --to)
                    # Complete with post URIs - not practical for completion
                    return 0
                    ;;
                *)
                    if [[ "$cur" == -* ]]; then
                        COMPREPLY=($(compgen -W "--to --debug" -- "$cur"))
                    fi
                    return 0
                    ;;
            esac
            ;;
        *)
            if [[ "$cur" == -* ]]; then
                COMPREPLY=($(compgen -W "--help --version --debug" -- "$cur"))
            fi
            return 0
            ;;
    esac
}

# Register the completion function
complete -o bashdefault -o default -o nospace -F _at_bot_completion at-bot
