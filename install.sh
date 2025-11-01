#!/bin/bash
# Installation script for atproto
# Simple installation for users without make

set -e

# Default installation prefix
PREFIX="${PREFIX:-/usr/local}"
BINDIR="$PREFIX/bin"
LIBDIR="$PREFIX/lib/atproto"
DOCDIR="$PREFIX/share/doc/atproto"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse command line arguments
INSTALL_MCP=0
AUTO_YES=0

while [[ $# -gt 0 ]]; do
    case $1 in
        --mcp|-mcp)
            INSTALL_MCP=1
            AUTO_YES=1
            shift
            ;;
        --yes|-y)
            AUTO_YES=1
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --mcp, -mcp     Install MCP server (requires Node.js)"
            echo "  --yes, -y       Auto-accept prompts"
            echo "  --help, -h      Show this help"
            echo ""
            echo "Environment:"
            echo "  PREFIX          Installation prefix (default: /usr/local)"
            echo ""
            echo "Examples:"
            echo "  ./install.sh                Install atproto CLI only"
            echo "  ./install.sh --mcp          Install CLI + MCP server"
            echo "  PREFIX=~/.local ./install.sh  Install to custom location"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Run '$0 --help' for usage information"
            exit 1
            ;;
    esac
done

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Detect Node.js path before potential sudo (nvm requires user environment)
NODE_PATH=""
NODE_VERSION=""

# Check if node is in PATH
if command -v node &> /dev/null; then
    NODE_PATH="$(command -v node)"
    NODE_VERSION="$(node --version 2>/dev/null || echo '')"
# Check common nvm locations
elif [ -x "$HOME/.nvm/versions/node/v22.16.0/bin/node" ]; then
    NODE_PATH="$HOME/.nvm/versions/node/v22.16.0/bin/node"
    NODE_VERSION="$($NODE_PATH --version 2>/dev/null || echo '')"
elif [ -x "/root/.nvm/versions/node/v22.16.0/bin/node" ]; then
    NODE_PATH="/root/.nvm/versions/node/v22.16.0/bin/node"
    NODE_VERSION="$($NODE_PATH --version 2>/dev/null || echo '')"
# Try to find any nvm node installation
elif [ -d "$HOME/.nvm/versions/node" ]; then
    # Find latest node version in nvm
    latest_node=$(ls -1 "$HOME/.nvm/versions/node" | grep -E '^v[0-9]+' | sort -V | tail -1)
    if [ -n "$latest_node" ] && [ -x "$HOME/.nvm/versions/node/$latest_node/bin/node" ]; then
        NODE_PATH="$HOME/.nvm/versions/node/$latest_node/bin/node"
        NODE_VERSION="$($NODE_PATH --version 2>/dev/null || echo '')"
    fi
elif [ -d "/root/.nvm/versions/node" ]; then
    # Find latest node version in root's nvm
    latest_node=$(ls -1 "/root/.nvm/versions/node" | grep -E '^v[0-9]+' | sort -V | tail -1)
    if [ -n "$latest_node" ] && [ -x "/root/.nvm/versions/node/$latest_node/bin/node" ]; then
        NODE_PATH="/root/.nvm/versions/node/$latest_node/bin/node"
        NODE_VERSION="$($NODE_PATH --version 2>/dev/null || echo '')"
    fi
fi

# Export NODE_PATH so npm can be found too
if [ -n "$NODE_PATH" ]; then
    export PATH="$(dirname "$NODE_PATH"):$PATH"
fi

echo "atproto Installation Script"
echo "==========================="
echo ""
echo "Installing to: $PREFIX"
echo ""

# Source setup script to check/install dependencies
echo "Checking dependencies..."
if ! bash "$SCRIPT_DIR/lib/setup.sh"; then
    echo ""
    read -p "Continue with installation despite missing dependencies? (y/n) " -r
    echo
    if ! [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 1
    fi
fi

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
$SUDO install -m 755 "$SCRIPT_DIR/bin/atproto" "$BINDIR/atproto"
$SUDO install -m 644 "$SCRIPT_DIR/lib/atproto.sh" "$LIBDIR/atproto.sh"
$SUDO install -m 644 "$SCRIPT_DIR/lib/config.sh" "$LIBDIR/config.sh"
$SUDO install -m 644 "$SCRIPT_DIR/lib/crypt.sh" "$LIBDIR/crypt.sh"
$SUDO install -m 644 "$SCRIPT_DIR/lib/reporter.sh" "$LIBDIR/reporter.sh"
$SUDO install -m 644 "$SCRIPT_DIR/lib/cli-utils.sh" "$LIBDIR/cli-utils.sh"
$SUDO install -m 644 "$SCRIPT_DIR/lib/validation.sh" "$LIBDIR/validation.sh"
$SUDO install -m 755 "$SCRIPT_DIR/lib/doc.sh" "$LIBDIR/doc.sh"
$SUDO install -m 755 "$SCRIPT_DIR/lib/setup.sh" "$LIBDIR/setup.sh"
$SUDO install -m 644 "$SCRIPT_DIR/README.md" "$DOCDIR/README.md"
$SUDO install -m 644 "$SCRIPT_DIR/LICENSE" "$DOCDIR/LICENSE"

echo ""
echo -e "${GREEN}✓ atproto CLI installed successfully!${NC}"

# Ask about MCP server installation if not specified via flag
if [ $INSTALL_MCP -eq 0 ] && [ $AUTO_YES -eq 0 ]; then
    echo ""
    echo -e "${BLUE}MCP Server Installation${NC}"
    echo "======================================"
    echo ""
    echo "The MCP (Model Context Protocol) server enables AI agents like"
    echo "GitHub Copilot and Claude to interact with Bluesky/AT Protocol."
    echo ""
    echo "Requirements: Node.js 18+"
    echo ""
    read -p "Do you want to install the MCP server? (y/n) " -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        INSTALL_MCP=1
    fi
fi

# Install MCP server if requested
if [ $INSTALL_MCP -eq 1 ]; then
    echo ""
    echo -e "${BLUE}Installing MCP Server...${NC}"
    echo ""
    
    # Check for Node.js (including nvm installations)
    if [ -z "$NODE_PATH" ] || [ ! -x "$NODE_PATH" ]; then
        echo -e "${YELLOW}Warning: Node.js is not installed or not found${NC}"
        echo "Please install Node.js 18+ from https://nodejs.org/"
        echo ""
        if [ $AUTO_YES -eq 0 ]; then
            read -p "Skip MCP server installation? (y/n) " -r
            echo
            if ! [[ $REPLY =~ ^[Yy]$ ]]; then
                echo "Installation cancelled."
                exit 1
            fi
        fi
        echo "Skipping MCP server installation (Node.js not found)"
    else
        echo "Found Node.js: $NODE_VERSION"
        
        # Build MCP server
        echo "Building MCP server..."
        cd "$SCRIPT_DIR/mcp-server"
        echo "  - Installing dependencies..."
        npm install --silent 2>&1 | grep -v "^npm WARN" || true
        echo "  - Compiling TypeScript..."
        npm run build --silent 2>&1 | grep -v "^npm WARN" || true
        cd "$SCRIPT_DIR"
        echo "  ✓ Build complete"
        
        # Install MCP server files to library directory
        echo "Installing MCP server files..."
        $SUDO mkdir -p "$LIBDIR/mcp-server/dist"
        $SUDO cp -r "$SCRIPT_DIR/mcp-server/dist/"* "$LIBDIR/mcp-server/dist/"
        $SUDO cp "$SCRIPT_DIR/mcp-server/package.json" "$LIBDIR/mcp-server/"
        
        # Install node_modules if they exist
        if [ -d "$SCRIPT_DIR/mcp-server/node_modules" ]; then
            $SUDO mkdir -p "$LIBDIR/mcp-server/node_modules"
            $SUDO cp -r "$SCRIPT_DIR/mcp-server/node_modules/"* "$LIBDIR/mcp-server/node_modules/" 2>/dev/null || true
        fi
        
        echo ""
        echo -e "${GREEN}✓ MCP server installed successfully!${NC}"
        echo ""
        echo -e "${BLUE}VS Code Configuration:${NC}"
        echo "Add to your .vscode/settings.json:"
        echo ""
        echo -e "${YELLOW}{"
        echo '  "github.copilot.chat.mcp.enabled": true,'
        echo '  "github.copilot.chat.mcp.servers": {'
        echo '    "atproto": {'
        echo "      \"command\": \"$BINDIR/atproto\","
        echo "      \"args\": [\"mcp-server\"]"
        echo '    }'
        echo '  }'
        echo -e "}${NC}"
        echo ""
        echo "Then reload VS Code window (Ctrl+Shift+P > Reload Window)"
    fi
fi

echo ""
echo -e "${GREEN}Installation complete!${NC}"
echo ""
echo "atproto is now installed. Try running:"
echo "  atproto help"
if [ $INSTALL_MCP -eq 1 ] && [ -n "$NODE_PATH" ]; then
    echo "  atproto mcp-server (for AI agents)"
fi
echo ""
echo "To uninstall, run:"
echo "  $SUDO rm -f $BINDIR/atproto"
echo "  $SUDO rm -rf $LIBDIR"
echo "  $SUDO rm -rf $DOCDIR"
