#!/bin/bash
# Install AT-bot shell completions
# Usage: ./scripts/install-completions.sh [bash|zsh|all]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

BASH_COMPLETION_DIR="${BASH_COMPLETION_DIR:-/etc/bash_completion.d}"
ZSH_COMPLETION_DIR="${ZSH_COMPLETION_DIR:-/usr/share/zsh/site-functions}"

# User-writable fallback locations
USER_BASH_DIR="$HOME/.bash_completion.d"
USER_ZSH_DIR="$HOME/.zsh/completions"

install_bash() {
    echo "Installing bash completions..."
    
    if [ -w "$BASH_COMPLETION_DIR" ]; then
        cp "$SCRIPT_DIR/at-bot-completion.bash" "$BASH_COMPLETION_DIR/at-bot"
        echo "✓ Installed to $BASH_COMPLETION_DIR/at-bot"
        echo "  Source it with: source $BASH_COMPLETION_DIR/at-bot"
    else
        mkdir -p "$USER_BASH_DIR"
        cp "$SCRIPT_DIR/at-bot-completion.bash" "$USER_BASH_DIR/at-bot"
        echo "✓ Installed to $USER_BASH_DIR/at-bot"
        echo "  Add to ~/.bashrc:"
        echo "  [ -f $USER_BASH_DIR/at-bot ] && source $USER_BASH_DIR/at-bot"
    fi
}

install_zsh() {
    echo "Installing zsh completions..."
    
    if [ -w "$ZSH_COMPLETION_DIR" ]; then
        cp "$SCRIPT_DIR/at-bot-completion.zsh" "$ZSH_COMPLETION_DIR/_at-bot"
        echo "✓ Installed to $ZSH_COMPLETION_DIR/_at-bot"
    else
        mkdir -p "$USER_ZSH_DIR"
        cp "$SCRIPT_DIR/at-bot-completion.zsh" "$USER_ZSH_DIR/_at-bot"
        echo "✓ Installed to $USER_ZSH_DIR/_at-bot"
        echo "  Add to ~/.zshrc:"
        echo "  fpath+=$USER_ZSH_DIR"
        echo "  autoload -Uz compinit && compinit"
    fi
}

install_all() {
    install_bash
    echo ""
    install_zsh
}

# Main
case "${1:-all}" in
    bash)
        install_bash
        ;;
    zsh)
        install_zsh
        ;;
    all|"")
        install_all
        ;;
    *)
        echo "Usage: $0 [bash|zsh|all]"
        exit 1
        ;;
esac

echo ""
echo "✓ Shell completion installation complete"
echo ""
echo "Usage:"
echo "  at-bot [TAB]         - See available commands"
echo "  at-bot post [TAB]    - See command-specific options"
echo ""
echo "Note: You may need to start a new shell session for completions to work"
