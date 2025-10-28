#!/bin/bash
# Uninstallation script for AT-bot

set -e

# Default installation prefix
PREFIX="${PREFIX:-/usr/local}"
BINDIR="$PREFIX/bin"
LIBDIR="$PREFIX/lib/at-bot"
DOCDIR="$PREFIX/share/doc/at-bot"

# Colors
YELLOW='\033[1;33m'
NC='\033[0m'

echo "AT-bot Uninstallation Script"
echo "============================="
echo ""
echo "Removing from: $PREFIX"
echo ""

# Check if we need sudo
SUDO=""
if [ ! -w "$PREFIX" ]; then
    echo "Note: Requires sudo for removal from $PREFIX"
    SUDO="sudo"
fi

# Check if installed
if [ ! -f "$BINDIR/at-bot" ]; then
    echo -e "${YELLOW}Warning: AT-bot doesn't appear to be installed at $PREFIX${NC}"
    echo ""
    echo "Checked for: $BINDIR/at-bot"
    exit 1
fi

# Remove files
echo "Removing files..."
$SUDO rm -f "$BINDIR/at-bot"
$SUDO rm -f "$BINDIR/at-bot-docs"
$SUDO rm -rf "$LIBDIR"
$SUDO rm -rf "$DOCDIR"

echo ""
echo "AT-bot uninstalled successfully."
echo ""
echo "Note: Your configuration in ~/.config/at-bot was not removed."
echo "To remove it manually, run:"
echo "  rm -rf ~/.config/at-bot"
