#compdef at-bot
# AT-bot zsh completion script
# Install with: cp scripts/at-bot-completion.zsh /usr/share/zsh/site-functions/_at-bot
# Or add to ~/.zshrc: fpath+=/path/to/scripts && autoload -Uz compinit && compinit

local -a commands
commands=(
    'help:Show help information'
    'login:Authenticate with Bluesky'
    'logout:Clear the current session'
    'whoami:Show current user information'
    'post:Create a new post'
    'feed:Read your home feed'
    'search:Search for posts'
    'follow:Follow a user'
    'unfollow:Unfollow a user'
    'followers:List followers'
    'following:List following'
    'profile:Get user profile'
    'profile-edit:Edit your profile'
    'like:Like a post'
    'reply:Reply to a post'
    'repost:Repost (rebleet) a post'
    'delete:Delete a post'
    'block:Block a user'
    'unblock:Unblock a user'
    'block-list:List blocked users'
)

_arguments -C \
    '1: :->command' \
    '*:: :->args'

case $state in
    command)
        _describe 'command' commands
        ;;
    args)
        case $line[1] in
            post)
                _arguments \
                    '1:text to post:' \
                    '--image[Path to image file]:(file)' \
                    '--debug[Enable debug mode]'
                ;;
            feed)
                _arguments \
                    '--limit[Limit number of posts]:(number)' \
                    '--debug[Enable debug mode]'
                ;;
            search)
                _arguments \
                    '1:search query:' \
                    '--limit[Limit number of results]:(number)' \
                    '--debug[Enable debug mode]'
                ;;
            follow|unfollow|block|unblock)
                _arguments \
                    '1:user handle:' \
                    '--debug[Enable debug mode]'
                ;;
            profile)
                _arguments \
                    '1:user handle (optional):' \
                    '--debug[Enable debug mode]'
                ;;
            profile-edit)
                _arguments \
                    '--display-name[Display name]:' \
                    '--description[Profile description]:' \
                    '--debug[Enable debug mode]'
                ;;
            reply)
                _arguments \
                    '1:reply text:' \
                    '--to[Post URI to reply to]:' \
                    '--debug[Enable debug mode]'
                ;;
            *)
                _arguments \
                    '--help[Show help]' \
                    '--version[Show version]' \
                    '--debug[Enable debug mode]'
                ;;
        esac
        ;;
esac
