#!/bin/bash
# AT-bot Documentation Compiler
# Purpose: Compile all markdown documentation into a single, formatted PDF
# Dependencies: pandoc (for MD->PDF conversion)

set -e

# Script directory detection
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Output configuration
OUTPUT_DIR="$PROJECT_ROOT/dist/docs"
COMPILED_MD="$OUTPUT_DIR/AT-bot_Complete_Documentation.md"
COMPILED_HTML="$OUTPUT_DIR/AT-bot_Complete_Documentation.html"
COMPILED_PDF="$OUTPUT_DIR/AT-bot_Complete_Documentation.pdf"
TOC_FILE="$OUTPUT_DIR/TOC.md"
CSS_FILE="$OUTPUT_DIR/documentation.css"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
info() {
    echo -e "${BLUE}ℹ${NC} $*"
}

success() {
    echo -e "${GREEN}✓${NC} $*"
}

warning() {
    echo -e "${YELLOW}⚠${NC} $*"
}

error() {
    echo -e "${RED}✗${NC} $*" >&2
}

# Check dependencies
check_dependencies() {
    info "Checking dependencies..."
    
    if ! command -v pandoc >/dev/null 2>&1; then
        error "pandoc is required but not installed"
        echo ""
        echo "Install pandoc:"
        echo "  Ubuntu/Debian: sudo apt-get install pandoc texlive-xetex"
        echo "  macOS: brew install pandoc basictex"
        echo "  Other: https://pandoc.org/installing.html"
        return 1
    fi
    
    success "All dependencies available"
    return 0
}

# Create output directory
prepare_output_directory() {
    info "Preparing output directory..."
    mkdir -p "$OUTPUT_DIR"
    success "Output directory ready: $OUTPUT_DIR"
}

# Document ordering strategy - defines the logical flow of documentation
# Documents are ordered by priority; unordered documents are discovered automatically
declare -a DOC_ORDER=(
    # Cover and Introduction
    "README.md"
    
    # Strategic Documents
    "PLAN.md"
    "AGENTS.md"
    
    # Standards and Guidelines
    "STYLE.md"
    "SECURITY.md"
    "CONTRIBUTING.md"
    
    # Project Management
    "TODO.md"
    
    # Technical Documentation
    "doc/ARCHITECTURE.md"
    "doc/QUICKSTART.md"
    "doc/QUICKREF.md"
    "doc/CONFIGURATION.md"
    "doc/DOCUMENTATION.md"
    
    # Feature Documentation
    "doc/ENCRYPTION.md"
    "doc/DEBUG_MODE.md"
    "doc/TESTING.md"
    "doc/PACKAGING.md"
    
    # MCP Server Documentation
    "mcp-server/README.md"
    "mcp-server/docs/QUICKSTART_MCP.md"
    "mcp-server/docs/MCP_TOOLS.md"
    "mcp-server/docs/MCP_INTEGRATION.md"
    
    # Progress Tracking
    "doc/progress/PROJECT_DASHBOARD.md"
    "doc/progress/MILESTONE_REPORT.md"
)

# Excluded directories and patterns from auto-discovery
declare -a EXCLUDED_PATTERNS=(
    "dist/*"
    "node_modules/*"
    ".git/*"
    ".github/*"
    ".vscode/*"
    "*/node_modules/*"
    "doc/sessions/*"
    "doc/progress/*"
    "*_old.md"
    "*_backup.md"
    "*/tests/*"
    "*/test-*"
    "TODO.md"
)

# Generate CSS for styling
generate_css() {
    info "Generating CSS stylesheet..."
    
    cat > "$CSS_FILE" << 'EOF'
/* AT-bot Documentation Stylesheet */

:root {
    --primary-color: #0066cc;
    --secondary-color: #004080;
    --accent-color: #00cc66;
    --text-color: #333333;
    --bg-color: #ffffff;
    --code-bg: #f5f5f5;
    --border-color: #dddddd;
}

@page {
    margin: 2.5cm;
    size: A4;
    
    @top-right {
        content: "AT-bot Documentation";
        font-size: 9pt;
        color: #666;
    }
    
    @bottom-center {
        content: counter(page);
        font-size: 9pt;
    }
}

body {
    font-family: 'Segoe UI', 'Helvetica Neue', Arial, sans-serif;
    font-size: 11pt;
    line-height: 1.6;
    color: var(--text-color);
    max-width: 100%;
    margin: 0;
    padding: 0;
}

/* Cover Page */
.cover-page {
    page-break-after: always;
    text-align: center;
    padding-top: 30%;
}

.cover-page h1 {
    font-size: 42pt;
    color: var(--primary-color);
    margin-bottom: 20pt;
    font-weight: 700;
}

.cover-page .subtitle {
    font-size: 18pt;
    color: var(--secondary-color);
    margin-bottom: 40pt;
}

.cover-page .metadata {
    font-size: 12pt;
    color: #666;
    margin-top: 60pt;
}

/* Table of Contents */
#TOC {
    page-break-after: always;
}

#TOC ul {
    list-style-type: none;
    padding-left: 0;
}

#TOC li {
    margin: 8pt 0;
}

#TOC a {
    text-decoration: none;
    color: var(--primary-color);
}

#TOC a:hover {
    text-decoration: underline;
}

/* Headings */
h1 {
    color: var(--primary-color);
    font-size: 28pt;
    font-weight: 700;
    margin-top: 30pt;
    margin-bottom: 20pt;
    page-break-after: avoid;
    border-bottom: 3px solid var(--primary-color);
    padding-bottom: 10pt;
}

h2 {
    color: var(--secondary-color);
    font-size: 22pt;
    font-weight: 600;
    margin-top: 25pt;
    margin-bottom: 15pt;
    page-break-after: avoid;
    border-bottom: 2px solid var(--border-color);
    padding-bottom: 8pt;
}

h3 {
    color: var(--secondary-color);
    font-size: 16pt;
    font-weight: 600;
    margin-top: 20pt;
    margin-bottom: 12pt;
    page-break-after: avoid;
}

h4 {
    color: var(--text-color);
    font-size: 13pt;
    font-weight: 600;
    margin-top: 15pt;
    margin-bottom: 10pt;
}

h5, h6 {
    color: var(--text-color);
    font-size: 11pt;
    font-weight: 600;
    margin-top: 12pt;
    margin-bottom: 8pt;
}

/* Paragraphs and Text */
p {
    margin: 10pt 0;
    text-align: justify;
    orphans: 3;
    widows: 3;
}

/* Links */
a {
    color: var(--primary-color);
    text-decoration: none;
}

a:hover {
    text-decoration: underline;
}

/* Code Blocks */
pre {
    background-color: var(--code-bg);
    border: 1px solid var(--border-color);
    border-radius: 4px;
    padding: 15pt;
    margin: 15pt 0;
    overflow-x: auto;
    page-break-inside: avoid;
    font-size: 9pt;
    line-height: 1.4;
}

code {
    font-family: 'Courier New', Courier, monospace;
    background-color: var(--code-bg);
    padding: 2pt 4pt;
    border-radius: 3px;
    font-size: 9.5pt;
}

pre code {
    background-color: transparent;
    padding: 0;
}

/* Lists */
ul, ol {
    margin: 10pt 0;
    padding-left: 25pt;
}

li {
    margin: 5pt 0;
}

/* Tables */
table {
    border-collapse: collapse;
    width: 100%;
    margin: 15pt 0;
    page-break-inside: avoid;
}

th {
    background-color: var(--primary-color);
    color: white;
    font-weight: 600;
    padding: 10pt;
    text-align: left;
    border: 1px solid var(--primary-color);
}

td {
    padding: 8pt 10pt;
    border: 1px solid var(--border-color);
}

tr:nth-child(even) {
    background-color: #f9f9f9;
}

/* Blockquotes */
blockquote {
    border-left: 4px solid var(--accent-color);
    margin: 15pt 0;
    padding: 10pt 20pt;
    background-color: #f9f9f9;
    font-style: italic;
    page-break-inside: avoid;
}

/* Horizontal Rules */
hr {
    border: none;
    border-top: 2px solid var(--border-color);
    margin: 25pt 0;
}

/* Images */
img {
    max-width: 100%;
    height: auto;
    display: block;
    margin: 15pt auto;
    page-break-inside: avoid;
}

/* Document Sections */
.document-section {
    page-break-before: always;
    margin-top: 0;
}

/* Footnotes */
.footnotes {
    margin-top: 40pt;
    padding-top: 20pt;
    border-top: 1px solid var(--border-color);
    font-size: 9pt;
}

/* Print-specific */
@media print {
    body {
        font-size: 10pt;
    }
    
    a[href]:after {
        content: " (" attr(href) ")";
        font-size: 8pt;
        color: #666;
    }
    
    a[href^="#"]:after {
        content: "";
    }
}

/* Syntax Highlighting (basic) */
.sourceCode .kw { color: #007020; font-weight: bold; }
.sourceCode .dt { color: #902000; }
.sourceCode .dv { color: #40a070; }
.sourceCode .bn { color: #40a070; }
.sourceCode .fl { color: #40a070; }
.sourceCode .ch { color: #4070a0; }
.sourceCode .st { color: #4070a0; }
.sourceCode .co { color: #60a0b0; font-style: italic; }
.sourceCode .ot { color: #007020; }
.sourceCode .al { color: red; font-weight: bold; }
.sourceCode .fu { color: #06287e; }
.sourceCode .er { color: red; font-weight: bold; }
EOF
    
    success "CSS stylesheet generated"
}

# Generate cover page
generate_cover_page() {
    info "Generating cover page..."
    
    local version="0.3.0"
    local date=$(date "+%B %d, %Y")
    
    cat > "$OUTPUT_DIR/cover.md" << EOF
---
title: "AT-bot Complete Documentation"
author: "AT-bot Development Team"
date: "$date"
---

# AT-bot

## Complete Documentation

### Version $version

The Definitive Guide to AT Protocol Command-Line Automation

---

**Generated:** $date  
**Project:** https://github.com/p3nGu1nZz/AT-bot  
**License:** MIT

\\newpage

EOF
    
    success "Cover page generated"
}

# Check if a path should be excluded from documentation
should_exclude() {
    local relative_path="$1"
    
    for pattern in "${EXCLUDED_PATTERNS[@]}"; do
        # Handle glob patterns
        case "$relative_path" in
            $pattern)
                return 0  # Should exclude
                ;;
        esac
    done
    
    return 1  # Should not exclude
}

# Extract title from markdown file
get_document_title() {
    local file="$1"
    local title=""
    
    # Try to get first H1 heading
    title=$(grep -m 1 "^# " "$file" 2>/dev/null | sed 's/^# //' || echo "")
    
    # Fallback to filename without extension
    if [ -z "$title" ]; then
        title=$(basename "$file" .md)
    fi
    
    echo "$title"
}

# Process individual document
process_document() {
    local file="$1"
    local output="$2"
    local is_first="${3:-false}"
    
    if [ ! -f "$PROJECT_ROOT/$file" ]; then
        warning "File not found: $file (skipping)"
        return
    fi
    
    info "Processing: $file"
    
    # Add page break before each document (except first)
    if [ "$is_first" = "false" ]; then
        echo -e "\n\\newpage\n" >> "$output"
    fi
    
    # Add document section marker with title
    local title=$(get_document_title "$PROJECT_ROOT/$file")
    echo "<!-- Document: $file -->" >> "$output"
    
    # Append document content
    cat "$PROJECT_ROOT/$file" >> "$output"
    echo -e "\n" >> "$output"
}

# Compile all documents into single markdown
compile_markdown() {
    info "Compiling markdown documents..."
    
    # Start with cover page
    cat "$OUTPUT_DIR/cover.md" > "$COMPILED_MD"
    
    # Track processed files to avoid duplicates
    declare -A processed_files
    
    # Process documents in defined order
    local first=true
    for doc in "${DOC_ORDER[@]}"; do
        if [ -f "$PROJECT_ROOT/$doc" ]; then
            # Check for duplicates
            local canonical_path=$(realpath "$PROJECT_ROOT/$doc" 2>/dev/null || echo "$PROJECT_ROOT/$doc")
            
            if [ -z "${processed_files[$canonical_path]}" ]; then
                process_document "$doc" "$COMPILED_MD" "$first"
                processed_files[$canonical_path]=1
                first=false
            else
                warning "Skipping duplicate: $doc"
            fi
        fi
    done
    
    # Add any remaining markdown files not in the order list
    info "Discovering additional markdown files..."
    local unordered_count=0
    
    while IFS= read -r -d '' file; do
        local relative_path="${file#$PROJECT_ROOT/}"
        local canonical_path=$(realpath "$file")
        
        # Skip if already processed
        if [ -n "${processed_files[$canonical_path]}" ]; then
            continue
        fi
        
        # Skip if in excluded patterns
        if should_exclude "$relative_path"; then
            continue
        fi
        
        # Process the unordered document
        warning "Found unordered document: $relative_path"
        process_document "$relative_path" "$COMPILED_MD" false
        processed_files[$canonical_path]=1
        ((unordered_count++))
    done < <(find "$PROJECT_ROOT" -name "*.md" -type f -print0)
    
    [ "$unordered_count" -gt 0 ] && info "Included $unordered_count additional unordered documents"
    
    success "Markdown compilation complete: $COMPILED_MD"
    
    # Display statistics
    local total_lines=$(wc -l < "$COMPILED_MD")
    local total_words=$(wc -w < "$COMPILED_MD")
    local file_size=$(du -h "$COMPILED_MD" | cut -f1)
    
    echo ""
    info "Compiled document statistics:"
    echo "  Lines: $total_lines"
    echo "  Words: $total_words"
    echo "  Size: $file_size"
    echo ""
}

# Convert markdown to HTML
convert_to_html() {
    info "Converting to HTML..."
    
    pandoc "$COMPILED_MD" \
        -f markdown+smart \
        -t html5 \
        --standalone \
        --toc \
        --toc-depth=3 \
        -H <(echo '<link rel="stylesheet" href="documentation.css">') \
        -V lang=en \
        -o "$COMPILED_HTML" 2>&1 || true
    
    if [ -f "$COMPILED_HTML" ] && [ -s "$COMPILED_HTML" ]; then
        success "HTML generated: $COMPILED_HTML"
        local html_size=$(du -h "$COMPILED_HTML" | cut -f1)
        info "HTML size: $html_size"
    else
        error "Failed to generate HTML"
        return 1
    fi
}

# Convert markdown to PDF
convert_to_pdf() {
    info "Converting to PDF (this may take a moment)..."
    
    pandoc "$COMPILED_MD" \
        -f markdown+smart \
        -t pdf \
        --pdf-engine=xelatex \
        --toc \
        --toc-depth=3 \
        --number-sections \
        --highlight-style=tango \
        -V geometry:margin=2.5cm \
        -V fontsize=11pt \
        -V documentclass=report \
        -V papersize=a4 \
        -V colorlinks=true \
        -V linkcolor=blue \
        -V urlcolor=blue \
        -V toccolor=black \
        -V mainfont="Liberation Serif" \
        -V monofont="Liberation Mono" \
        -o "$COMPILED_PDF" 2>&1 || true
    
    if [ -f "$COMPILED_PDF" ] && [ -s "$COMPILED_PDF" ]; then
        success "PDF generated: $COMPILED_PDF"
        
        # Display file size
        local pdf_size=$(du -h "$COMPILED_PDF" | cut -f1)
        info "PDF size: $pdf_size"
    else
        error "Failed to generate PDF"
        echo ""
        warning "PDF generation requires XeLaTeX. Install with:"
        echo "  Ubuntu/Debian: sudo apt-get install texlive-xetex"
        echo "  macOS: brew install basictex"
        return 1
    fi
}

# Main execution
main() {
    echo ""
    echo -e "${CYAN}════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  AT-bot Documentation Compiler${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════${NC}"
    echo ""
    
    # Check dependencies
    check_dependencies || exit 1
    
    # Prepare output
    prepare_output_directory
    
    # Generate assets
    generate_css
    generate_cover_page
    
    # Compile documents
    compile_markdown
    
    # Convert to formats
    convert_to_html
    convert_to_pdf
    
    # Summary
    echo ""
    echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  Documentation Compilation Complete!${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "Generated files:"
    echo "  📝 Markdown: $COMPILED_MD"
    echo "  🌐 HTML: $COMPILED_HTML"
    echo "  📄 PDF: $COMPILED_PDF"
    echo ""
    echo "Share the PDF with: ${CYAN}$COMPILED_PDF${NC}"
    echo ""
}

# Run main if executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi
