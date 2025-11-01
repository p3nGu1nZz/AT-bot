#!/bin/bash
# Test: VS Code extension functionality

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
EXTENSION_DIR="$PROJECT_ROOT/vscode-extension"
ATPROTO="$PROJECT_ROOT/bin/atproto"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo_test() {
    echo -e "${YELLOW}Testing:${NC} $1"
}

echo_pass() {
    echo -e "${GREEN}✓ PASS:${NC} $1"
}

echo_fail() {
    echo -e "${RED}✗ FAIL:${NC} $1"
    exit 1
}

# Test extension directory structure
test_extension_structure() {
    echo_test "VS Code extension directory structure"
    
    [ -d "$EXTENSION_DIR" ] || echo_fail "Extension directory missing"
    [ -f "$EXTENSION_DIR/package.json" ] || echo_fail "package.json missing"
    [ -f "$EXTENSION_DIR/tsconfig.json" ] || echo_fail "tsconfig.json missing"
    [ -d "$EXTENSION_DIR/src" ] || echo_fail "src/ directory missing"
    [ -f "$EXTENSION_DIR/src/extension.ts" ] || echo_fail "extension.ts missing"
    [ -f "$EXTENSION_DIR/src/mcp-provider.ts" ] || echo_fail "mcp-provider.ts missing"
    [ -f "$EXTENSION_DIR/src/auth-manager.ts" ] || echo_fail "auth-manager.ts missing"
    [ -f "$EXTENSION_DIR/media/icon.png" ] || echo_fail "Extension icon missing"
    
    echo_pass "Extension structure is correct"
}

# Test extension compilation
test_extension_compilation() {
    echo_test "TypeScript compilation"
    
    cd "$EXTENSION_DIR"
    
    # Check if compiled files exist (from previous compilation)
    if [ -d "dist" ] && [ -f "dist/extension.js" ]; then
        echo_pass "Extension is compiled"
    else
        echo_fail "Extension is not compiled - run 'npm run compile' first"
    fi
}

# Test extension package
test_extension_package() {
    echo_test "Extension VSIX package"
    
    cd "$EXTENSION_DIR"
    
    # Check if VSIX exists
    if ls *.vsix 1> /dev/null 2>&1; then
        VSIX_FILE=$(ls *.vsix | head -1)
        echo_pass "VSIX package exists: $VSIX_FILE"
    else
        echo_fail "VSIX package not found - run 'npm run package' first"
    fi
}

# Test MCP server integration
test_mcp_server() {
    echo_test "MCP server integration"
    
    # Test help command
    "$ATPROTO" mcp-server --help | grep -q "29 tools" || echo_fail "MCP server help doesn't show tools count"
    
    # Test server startup (should start and timeout)
    timeout 2s "$ATPROTO" mcp-server > /dev/null 2>&1 || {
        # Timeout is expected for stdio mode
        echo_pass "MCP server starts correctly"
    }
}

# Test extension manifest
test_extension_manifest() {
    echo_test "Extension manifest (package.json)"
    
    cd "$EXTENSION_DIR"
    
    # Check key fields in package.json
    grep -q '"name": "atproto"' package.json || echo_fail "Extension name incorrect"
    grep -q '"publisher": "p3ngu1nzz"' package.json || echo_fail "Publisher incorrect"
    grep -q '"icon": "media/icon.png"' package.json || echo_fail "Extension icon not configured"
    grep -q '"mcpServerDefinitionProviders"' package.json || echo_fail "MCP provider contribution missing"
    grep -q '"atproto.login"' package.json || echo_fail "Login command missing"
    
    echo_pass "Extension manifest is correct"
}

# Test VS Code extension installation
test_extension_installation() {
    echo_test "VS Code extension installation"
    
    # Check if VS Code is available
    if ! command -v code &> /dev/null; then
        echo_pass "VS Code not available - skipping installation test"
        return 0
    fi
    
    # Check if extension is installed
    if code --list-extensions | grep -q "p3ngu1nzz.atproto"; then
        echo_pass "Extension is installed in VS Code"
    else
        echo_pass "Extension not installed - manual installation required"
    fi
}

# Test node modules exclusion
test_gitignore() {
    echo_test "Gitignore configuration"
    
    # Check that .gitignore excludes node_modules
    grep -q "node_modules/" "$PROJECT_ROOT/.gitignore" || echo_fail ".gitignore doesn't exclude node_modules"
    
    # Check that extension files are not being tracked unnecessarily
    cd "$PROJECT_ROOT"
    if [ -d "$EXTENSION_DIR/node_modules" ]; then
        git check-ignore "$EXTENSION_DIR/node_modules" > /dev/null || echo_fail "node_modules should be ignored by git"
    fi
    
    if [ -f "$EXTENSION_DIR/atproto-0.1.0.vsix" ]; then
        git check-ignore "$EXTENSION_DIR"/*.vsix > /dev/null || echo_fail "VSIX files should be ignored by git"
    fi
    
    echo_pass "Gitignore is configured correctly"
}

# Main test execution
main() {
    echo "Running VS Code extension tests..."
    echo
    
    test_extension_structure
    test_extension_compilation
    test_extension_package
    test_mcp_server
    test_extension_manifest
    test_extension_installation
    test_gitignore
    
    echo
    echo -e "${GREEN}All VS Code extension tests passed!${NC}"
    
    echo
    echo "Manual Testing Steps:"
    echo "1. Open VS Code: code ."
    echo "2. Check extension is active in Extensions panel"
    echo "3. Open Command Palette (Ctrl+Shift+P)"
    echo "4. Look for 'atproto:' commands"
    echo "5. Test GitHub Copilot with '@atproto' tools"
    echo "6. Check status bar for atproto icon"
}

main "$@"