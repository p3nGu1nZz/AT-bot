#!/bin/bash
# Installation script for AT-bot
# Simple installation for users without make

set -e

# Default installation prefix
PREFIX="${PREFIX:-/usr/local}"
BINDIR="$PREFIX/bin"
LIBDIR="$PREFIX/lib/at-bot"
DOCDIR="$PREFIX/share/doc/at-bot"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

echo "AT-bot Installation Script"
echo "=========================="
echo ""
echo "Installing to: $PREFIX"
echo ""

# Check if we need sudo
SUDO=""
if [ ! -w "$PREFIX" ]; then
    echo "Note: Requires sudo for installation to $PREFIX"
    SUDO="sudo"
fi

# Create directories
echo "Creating directories..."
$SUDO mkdir -p "$BINDIR"
$SUDO mkdir -p "$LIBDIR"
$SUDO mkdir -p "$DOCDIR"

# Install files
echo "Installing files..."
$SUDO install -m 755 "$SCRIPT_DIR/bin/at-bot" "$BINDIR/at-bot"
$SUDO install -m 755 "$SCRIPT_DIR/bin/at-bot-docs" "$BINDIR/at-bot-docs"
$SUDO install -m 644 "$SCRIPT_DIR/lib/atproto.sh" "$LIBDIR/atproto.sh"
$SUDO install -m 644 "$SCRIPT_DIR/lib/config.sh" "$LIBDIR/config.sh"
$SUDO install -m 644 "$SCRIPT_DIR/lib/crypt.sh" "$LIBDIR/crypt.sh"
$SUDO install -m 755 "$SCRIPT_DIR/lib/doc.sh" "$LIBDIR/doc.sh"
$SUDO install -m 644 "$SCRIPT_DIR/README.md" "$DOCDIR/README.md"
$SUDO install -m 644 "$SCRIPT_DIR/LICENSE" "$DOCDIR/LICENSE"

echo ""
echo -e "${GREEN}Installation complete!${NC}"
echo ""
echo "AT-bot is now installed. Try running:"
echo "  at-bot help"
echo ""
echo "To uninstall, run:"
echo "  $SUDO rm -f $BINDIR/at-bot"
echo "  $SUDO rm -rf $LIBDIR"
echo "  $SUDO rm -rf $DOCDIR"
