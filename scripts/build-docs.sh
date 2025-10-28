#!/bin/bash
# AT-bot Documentation Build Script
# Builds documentation using include/exclude configuration
# Usage: ./scripts/build-docs.sh [--clean] [--verbose] [--format html|markdown|pdf]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$PROJECT_ROOT/docs.config.yaml"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Parse command-line arguments
CLEAN_BUILD=false
VERBOSE=false
FORMAT="html"

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
        --format)
            FORMAT="$2"
            shift 2
            ;;
        --help)
            cat << 'EOF'
Usage: ./scripts/build-docs.sh [options]

Options:
  --clean              Clean output directory before building
  --verbose            Enable verbose output
  --format FORMAT      Output format: html, markdown, pdf (default: html)
  --help               Show this help message

Examples:
  ./scripts/build-docs.sh                    # Build HTML documentation
  ./scripts/build-docs.sh --clean --verbose  # Clean rebuild with verbose output
  ./scripts/build-docs.sh --format markdown  # Build Markdown documentation

Configuration:
  Documentation build configuration is controlled by: docs.config.yaml
  - Exclude patterns to skip files/directories
  - Include patterns to explicitly include files
  - Output format and location settings
  - Metadata and search configuration
EOF
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}Error: Configuration file not found: $CONFIG_FILE${NC}"
    exit 1
fi

# Extract output directory from config
OUTPUT_DIR=$(grep -A5 "^output:" "$CONFIG_FILE" | grep "directory:" | awk '{print $2}' | tr -d '"')
OUTPUT_DIR="${OUTPUT_DIR:-.dist/docs}"

# Make it absolute if relative
if [[ ! "$OUTPUT_DIR" = /* ]]; then
    OUTPUT_DIR="$PROJECT_ROOT/$OUTPUT_DIR"
fi

echo -e "${BLUE}📚 AT-bot Documentation Build${NC}"
echo "=================================="
echo -e "Project root: ${YELLOW}$PROJECT_ROOT${NC}"
echo -e "Config file:  ${YELLOW}$CONFIG_FILE${NC}"
echo -e "Output dir:   ${YELLOW}$OUTPUT_DIR${NC}"
echo -e "Format:       ${YELLOW}$FORMAT${NC}"
echo ""

# Clean output directory if requested
if [ "$CLEAN_BUILD" = true ]; then
    echo -e "${YELLOW}🧹 Cleaning output directory...${NC}"
    if [ -d "$OUTPUT_DIR" ]; then
        rm -rf "$OUTPUT_DIR"
    fi
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Function to check if file matches pattern
matches_pattern() {
    local file="$1"
    local pattern="$2"
    
    # Convert glob pattern to regex
    pattern="${pattern//\*/.*}"
    pattern="${pattern//\?/.}"
    
    if [[ "$file" =~ ^$pattern$ ]]; then
        return 0
    else
        return 1
    fi
}

# Function to check if file should be excluded
should_exclude() {
    local file="$1"
    local rel_path="${file#$PROJECT_ROOT/}"
    
    # Read exclude patterns from config
    local in_exclude=false
    while IFS= read -r line; do
        if [[ "$line" =~ ^exclude: ]]; then
            in_exclude=true
            continue
        fi
        
        if [[ "$line" =~ ^[a-z_]+: ]] && [[ ! "$line" =~ ^exclude: ]]; then
            in_exclude=false
            continue
        fi
        
        if [ "$in_exclude" = true ]; then
            # Remove leading spaces and dash
            pattern=$(echo "$line" | sed 's/^[[:space:]]*-[[:space:]]*//')
            pattern=$(echo "$pattern" | tr -d '"' | tr -d "'")
            
            if [ -n "$pattern" ] && matches_pattern "$rel_path" "$pattern"; then
                if [ "$VERBOSE" = true ]; then
                    echo -e "  ${RED}✗${NC} Excluded: $rel_path (matched: $pattern)"
                fi
                return 0
            fi
        fi
    done < "$CONFIG_FILE"
    
    return 1
}

# Function to check if file should be included
should_include() {
    local file="$1"
    local rel_path="${file#$PROJECT_ROOT/}"
    
    # Check if there's an include list
    local has_include=false
    local include_list=""
    
    local in_include=false
    while IFS= read -r line; do
        if [[ "$line" =~ ^include: ]]; then
            in_include=true
            has_include=true
            continue
        fi
        
        if [[ "$line" =~ ^[a-z_]+: ]] && [[ ! "$line" =~ ^include: ]]; then
            in_include=false
            continue
        fi
        
        if [ "$in_include" = true ]; then
            # Remove leading spaces and dash
            pattern=$(echo "$line" | sed 's/^[[:space:]]*-[[:space:]]*//')
            pattern=$(echo "$pattern" | tr -d '"' | tr -d "'")
            
            if [ -n "$pattern" ]; then
                include_list="$include_list|$pattern"
            fi
        fi
    done < "$CONFIG_FILE"
    
    # If include list exists, check if file matches
    if [ "$has_include" = true ] && [ -n "$include_list" ]; then
        include_list="${include_list:1}"  # Remove leading |
        
        IFS='|' read -ra patterns <<< "$include_list"
        for pattern in "${patterns[@]}"; do
            if matches_pattern "$rel_path" "$pattern"; then
                if [ "$VERBOSE" = true ]; then
                    echo -e "  ${GREEN}✓${NC} Included: $rel_path (matched: $pattern)"
                fi
                return 0
            fi
        done
        return 1
    fi
    
    # If no include list, include by default (unless excluded)
    return 0
}

# Process files
echo -e "${BLUE}📝 Processing files...${NC}"

files_found=0
files_included=0
files_excluded=0

# Find all markdown and documentation files
while IFS= read -r file; do
    ((files_found++))
    
    if should_exclude "$file"; then
        ((files_excluded++))
    elif should_include "$file"; then
        ((files_included++))
        
        # Copy file to output directory
        rel_path="${file#$PROJECT_ROOT/}"
        out_file="$OUTPUT_DIR/$rel_path"
        mkdir -p "$(dirname "$out_file")"
        cp "$file" "$out_file"
        
        if [ "$VERBOSE" = true ]; then
            echo -e "  ${GREEN}→${NC} Copied: $rel_path"
        fi
    else
        ((files_excluded++))
    fi
done < <(find "$PROJECT_ROOT" \( -name "*.md" -o -name "*.sh" \) -type f 2>/dev/null | grep -v node_modules | grep -v "\.git/" | sort)

echo ""
echo -e "${BLUE}📊 Build Statistics${NC}"
echo "=================================="
echo -e "Files found:    ${YELLOW}$files_found${NC}"
echo -e "Files included: ${GREEN}$files_included${NC}"
echo -e "Files excluded: ${RED}$files_excluded${NC}"
echo ""

# Create index.html if HTML format
if [ "$FORMAT" = "html" ]; then
    echo -e "${BLUE}🌐 Generating HTML index...${NC}"
    
    cat > "$OUTPUT_DIR/index.html" << 'HTMLEOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AT-bot Documentation</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            line-height: 1.6;
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
            color: #333;
            background: #f5f5f5;
        }
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 40px 20px;
            border-radius: 8px;
            margin-bottom: 30px;
            text-align: center;
        }
        .header h1 {
            margin: 0;
            font-size: 2.5em;
        }
        .header p {
            margin: 10px 0 0 0;
            opacity: 0.9;
        }
        .nav-section {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .nav-card {
            background: white;
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .nav-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 4px 16px rgba(0,0,0,0.15);
        }
        .nav-card h3 {
            margin-top: 0;
            color: #667eea;
        }
        .nav-card ul {
            list-style: none;
            padding: 0;
            margin: 0;
        }
        .nav-card li {
            margin: 8px 0;
        }
        .nav-card a {
            color: #667eea;
            text-decoration: none;
            transition: color 0.2s;
        }
        .nav-card a:hover {
            color: #764ba2;
            text-decoration: underline;
        }
        .footer {
            margin-top: 40px;
            padding-top: 20px;
            border-top: 1px solid #ddd;
            text-align: center;
            color: #666;
            font-size: 0.9em;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>📚 AT-bot Documentation</h1>
        <p>A simple CLI tool for Bluesky AT Protocol automation</p>
    </div>
    
    <div class="nav-section">
        <div class="nav-card">
            <h3>📖 Getting Started</h3>
            <ul>
                <li><a href="README.html">README</a> - Project overview</li>
                <li><a href="CONTRIBUTING.html">Contributing</a> - How to contribute</li>
            </ul>
        </div>
        
        <div class="nav-card">
            <h3>🎯 Project Info</h3>
            <ul>
                <li><a href="PLAN.html">Development Plan</a> - Strategic roadmap</li>
                <li><a href="TODO.html">TODO List</a> - Tasks and features</li>
                <li><a href="STYLE.html">Style Guide</a> - Code standards</li>
            </ul>
        </div>
        
        <div class="nav-card">
            <h3>🤖 AI & Agents</h3>
            <ul>
                <li><a href="AGENTS.html">Agent Integration</a> - AI automation patterns</li>
                <li><a href="mcp-server/docs/QUICKSTART_MCP.html">MCP Quickstart</a> - Get started with MCP</li>
                <li><a href="mcp-server/docs/MCP_TOOLS.html">MCP Tools</a> - Tool reference</li>
            </ul>
        </div>
        
        <div class="nav-card">
            <h3>📚 Documentation</h3>
            <ul>
                <li><a href="doc/CONTRIBUTING.html">Development Guide</a></li>
                <li><a href="doc/SECURITY.html">Security Guide</a></li>
                <li><a href="doc/PACKAGING.html">Packaging Guide</a></li>
                <li><a href="doc/QUICKSTART.html">Quick Reference</a></li>
            </ul>
        </div>
    </div>
    
    <div class="footer">
        <p>AT-bot &copy; 2025 - A POSIX-compliant CLI tool for Bluesky automation</p>
        <p><a href="https://github.com/p3nGu1nZz/AT-bot">GitHub Repository</a></p>
    </div>
</body>
</html>
HTMLEOF
fi

echo -e "${GREEN}✓ Documentation build complete!${NC}"
echo ""
echo -e "Output location: ${YELLOW}$OUTPUT_DIR${NC}"
echo ""
echo "Next steps:"
echo "  - View documentation in: $OUTPUT_DIR"
if [ "$FORMAT" = "html" ]; then
    echo "  - Open in browser: file://$OUTPUT_DIR/index.html"
fi
