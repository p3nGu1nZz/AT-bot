#!/bin/bash
# AT-bot Documentation Build Script
# Wrapper around lib/doc.sh for building documentation
# Usage: ./scripts/build-docs.sh [--clean] [--verbose]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DOC_COMPILER="$PROJECT_ROOT/lib/doc.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Parse command-line arguments
CLEAN_BUILD=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --clean)
            CLEAN_BUILD=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --help)
            cat << 'EOF'
Usage: ./scripts/build-docs.sh [options]

Options:
  --clean              Clean output directory before building
  --verbose            Enable verbose output (passes through to doc.sh)
  --help               Show this help message

Examples:
  ./scripts/build-docs.sh                    # Build documentation
  ./scripts/build-docs.sh --clean --verbose  # Clean rebuild with verbose output

Configuration:
  Documentation build is controlled by:
  - lib/doc.sh        - Main documentation compiler with exclude/include patterns
  - DOC_ORDER array   - Ordered list of documents to include
  - EXCLUDED_PATTERNS - Patterns to exclude from auto-discovery

See lib/doc.sh for documentation ordering and exclusion configuration.
EOF
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Check if doc compiler exists
if [ ! -f "$DOC_COMPILER" ]; then
    echo -e "${RED}Error: Documentation compiler not found: $DOC_COMPILER${NC}"
    exit 1
fi

OUTPUT_DIR="$PROJECT_ROOT/dist/docs"

echo -e "${BLUE}📚 AT-bot Documentation Build${NC}"
echo "=================================="
echo -e "Project root:  ${YELLOW}$PROJECT_ROOT${NC}"
echo -e "Doc compiler:  ${YELLOW}$DOC_COMPILER${NC}"
echo -e "Output dir:    ${YELLOW}$OUTPUT_DIR${NC}"
echo ""

# Clean output directory if requested
if [ "$CLEAN_BUILD" = true ]; then
    echo -e "${YELLOW}🧹 Cleaning output directory...${NC}"
    if [ -d "$OUTPUT_DIR" ]; then
        rm -rf "$OUTPUT_DIR"
    fi
    echo ""
fi

# Run the documentation compiler
echo -e "${BLUE}🔨 Running documentation compiler...${NC}"
bash "$DOC_COMPILER"

echo ""
echo -e "${GREEN}✓ Documentation build complete!${NC}"
echo ""
echo -e "Output location: ${YELLOW}$OUTPUT_DIR${NC}"
echo ""
echo "Generated files:"
echo "  - AT-bot_Complete_Documentation.md (markdown)"
echo "  - AT-bot_Complete_Documentation.html (HTML)"
echo "  - AT-bot_Complete_Documentation.pdf (PDF)"
echo "  - documentation.css (stylesheet)"
echo ""
echo "To view documentation:"
echo "  - Markdown: cat $OUTPUT_DIR/AT-bot_Complete_Documentation.md"
echo "  - HTML: open file://$OUTPUT_DIR/AT-bot_Complete_Documentation.html"
echo "  - PDF: open $OUTPUT_DIR/AT-bot_Complete_Documentation.pdf"
