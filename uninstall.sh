#!/bin/bash
# Uninstallation script for atproto

set -e

# Default installation prefix
PREFIX="${PREFIX:-/usr/local}"
BINDIR="$PREFIX/bin"
LIBDIR="$PREFIX/lib/atproto"
DOCDIR="$PREFIX/share/doc/atproto"

# Colors
YELLOW='\033[1;33m'
NC='\033[0m'

echo "atproto Uninstallation Script"
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
if [ ! -f "$BINDIR/atproto" ]; then
    echo -e "${YELLOW}Warning: atproto doesn't appear to be installed at $PREFIX${NC}"
    echo ""
    echo "Checked for: $BINDIR/atproto"
    exit 1
fi

# Remove files
echo "Removing files..."
$SUDO rm -f "$BINDIR/atproto"
$SUDO rm -rf "$LIBDIR"
$SUDO rm -rf "$DOCDIR"

echo ""
echo "atproto uninstalled successfully."
echo ""
echo "Note: Your configuration in ~/.config/atproto was not removed."
echo "To remove it manually, run:"
echo "  rm -rf ~/.config/atproto"
