#!/bin/bash
# AT-bot Documentation Compiler
# Purpose: Compile all markdown documentation into a single, formatted PDF
# Dependencies: pandoc (markdown->HTML), wkhtmltopdf (HTML->PDF), yq (YAML parsing)
# 
# Conversion pipeline: 
# 1. Generate TOC from docs.config.yaml
# 2. Markdown files -> Compiled markdown (with TOC, main docs, then API.md appendix)
# 3. Compiled markdown -> HTML template
# 4. HTML template -> PDF

set -e

# Script directory detection
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Configuration files
CONFIG_FILE="$PROJECT_ROOT/docs.config.yaml"

# Output configuration
OUTPUT_DIR="$PROJECT_ROOT/dist/docs"
COMPILED_MD="$OUTPUT_DIR/AT-bot_Complete_Documentation.md"
COMPILED_PDF="$OUTPUT_DIR/AT-bot_Complete_Documentation.pdf"
TOC_SOURCE="$PROJECT_ROOT/doc/TOC.md"
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
    
    local missing=0
    
    if ! command -v pandoc >/dev/null 2>&1; then
        error "pandoc is required but not installed"
        echo ""
        echo "Install pandoc:"
        echo "  Ubuntu/Debian: sudo apt-get install pandoc"
        echo "  Fedora/RHEL: sudo dnf install pandoc"
        echo "  macOS: brew install pandoc"
        echo "  Alpine: apk add pandoc"
        echo "  Other: https://pandoc.org/installing.html"
        missing=$((missing + 1))
    else
        success "pandoc available"
    fi
    
    if ! command -v wkhtmltopdf >/dev/null 2>&1; then
        error "wkhtmltopdf is required but not installed"
        echo ""
        echo "Install wkhtmltopdf:"
        echo "  Ubuntu/Debian: sudo apt-get install wkhtmltopdf"
        echo "  Fedora/RHEL: sudo dnf install wkhtmltopdf"
        echo "  macOS: brew install wkhtmltopdf"
        echo "  Alpine: apk add wkhtmltopdf"
        missing=$((missing + 1))
    else
        success "wkhtmltopdf available"
    fi
    
    if [ $missing -gt 0 ]; then
        error "Missing $missing required dependency/dependencies"
        return 1
    fi
    
    success "All dependencies available"
    return 0
}

# Generate Table of Contents from source docs
generate_toc() {
    info "Generating Table of Contents..."
    
    # Call the TOC generator script from lib/
    if [ -x "$SCRIPT_DIR/gen-toc.sh" ]; then
        bash "$SCRIPT_DIR/gen-toc.sh" || {
            warning "TOC generation had issues, continuing with existing TOC"
        }
        if [ -f "$TOC_SOURCE" ]; then
            success "TOC generated: $TOC_SOURCE"
        fi
    else
        warning "TOC generator not found, skipping TOC generation"
    fi
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
    # Cover Page (Title + Preamble)
    "doc/COVER.md"
    
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
    "doc/FAQ.md"
    "doc/ENVIRONMENT_VARIABLES.md"
    "doc/EXAMPLES.md"
    
    # Feature Documentation
    "doc/ENCRYPTION.md"
    "doc/DEBUG_MODE.md"
    "doc/TESTING.md"
    "doc/TESTING_GUIDE.md"
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
        echo "" >> "$output"
        echo "---" >> "$output"
        echo "" >> "$output"
    fi
    
    # Add document section marker with title
    local title=$(get_document_title "$PROJECT_ROOT/$file")
    echo "<!-- Document: $file -->" >> "$output"
    
    # Append document content, stripping YAML front matter
    # Convert standalone --- to ~~~ to avoid confusion with document separators
    tail -n +1 "$PROJECT_ROOT/$file" | awk '
    /^---$/ && NR==1 { in_frontmatter=1; next }
    /^---$/ && in_frontmatter==1 { in_frontmatter=0; next }
    in_frontmatter==1 { next }
    /^---$/ { print "~~~"; next }
    { print }
    ' >> "$output"
    
    echo "" >> "$output"
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
    
    # Add any remaining markdown files not in the order list (disabled for performance)
    info "Markdown compilation complete: $COMPILED_MD"
    
    # Skip unordered file discovery for now - it's too slow
    # uncomment below to re-enable auto-discovery of unordered markdown files
    #
    # info "Discovering additional markdown files..."
    # local unordered_count=0
    # ... (rest of unordered discovery code would go here)
    
    # Display statistics
    local total_lines=$(wc -l < "$COMPILED_MD")
    local total_words=$(wc -w < "$COMPILED_MD")
    local file_size=$(du -h "$COMPILED_MD" | cut -f1)
    
    echo ""
    info "Compiled document statistics:"
    echo "  Lines: $total_lines"
    echo "  Words: $total_words"
    echo "  Size: $file_size"
}

# Create HTML template with CSS styling for PDF conversion
create_html_template() {
    local template_file="$1"
    
    cat > "$template_file" << 'TEMPLATE_EOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>AT-bot - Complete Documentation</title>
    <style>
        /* Base styling */
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            line-height: 1.6;
            max-width: 900px;
            margin: 0 auto;
            padding: 20px;
            color: #333;
            font-size: 11pt;
        }

        /* Headings with visual hierarchy */
        h1 {
            color: #2c3e50;
            border-bottom: 3px solid #3498db;
            padding-bottom: 10px;
            margin-top: 30px;
            font-size: 24pt;
            page-break-after: avoid;
        }
        h2 {
            color: #34495e;
            border-bottom: 2px solid #95a5a6;
            padding-bottom: 8px;
            margin-top: 25px;
            font-size: 18pt;
            page-break-after: avoid;
        }
        h3 {
            color: #7f8c8d;
            margin-top: 20px;
            font-size: 14pt;
            page-break-after: avoid;
        }

        /* Code blocks */
        code {
            background-color: #f6f8fa;
            padding: 2px 5px;
            border-radius: 3px;
            font-family: 'Courier New', monospace;
            font-size: 9pt;
            border: 1px solid #e1e4e8;
        }
        pre {
            background-color: #f6f8fa;
            padding: 12px;
            border-radius: 5px;
            overflow-x: auto;
            border-left: 4px solid #3498db;
            border: 1px solid #d1d5da;
            line-height: 1.4;
            page-break-inside: avoid;
        }
        pre code {
            background-color: transparent;
            padding: 0;
            border: none;
            font-size: 9pt;
        }

        /* Tables */
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 15px 0;
            font-size: 10pt;
            page-break-inside: auto;
        }
        table thead {
            background: #f1f3f5;
            font-weight: bold;
        }
        table tr {
            page-break-inside: avoid;
            page-break-after: auto;
        }
        table th, table td {
            border: 1px solid #dee2e6;
            padding: 8px 12px;
            text-align: left;
        }
        table tr:nth-child(even) {
            background: #f8f9fa;
        }

        /* Blockquotes */
        blockquote {
            background: #fffbea;
            border-left: 4px solid #f39c12;
            padding: 10px 15px;
            margin: 15px 0;
            font-style: italic;
            page-break-inside: avoid;
        }

        /* Lists */
        ul, ol {
            page-break-inside: avoid;
            margin: 10px 0;
        }

        /* Links */
        a {
            color: #3498db;
            text-decoration: none;
        }
    </style>
</head>
<body>
$body$
</body>
</html>
TEMPLATE_EOF

    return 0
}

# Convert markdown to PDF using wkhtmltopdf
convert_to_pdf() {
    info "Converting to PDF using wkhtmltopdf..."
    
    local build_dir="dist/docs"
    local html_template="$build_dir/template.html"
    local html_intermediate="$build_dir/documentation.html"
    local pdf_file="$build_dir/AT-bot_Complete_Documentation.pdf"
    
    # Convert to absolute paths for wkhtmltopdf compatibility
    local abs_html_intermediate="$(cd "$(dirname "$html_intermediate")" && pwd)/$(basename "$html_intermediate")"
    local abs_pdf_file="$(cd "$(dirname "$pdf_file")" && pwd)/$(basename "$pdf_file")"
    
    # Create HTML template with CSS styling
    if ! create_html_template "$html_template"; then
        error "Failed to create HTML template"
        return 1
    fi
    
    # Step 1: Convert markdown to HTML using pandoc
    info "Converting markdown to HTML..."
    if ! pandoc "$COMPILED_MD" \
        --from markdown \
        --to html \
        --standalone \
        --toc \
        --toc-depth=3 \
        --template "$html_template" \
        --output "$abs_html_intermediate" 2>/dev/null; then
        error "Pandoc conversion to HTML failed"
        return 1
    fi
    
    success "HTML generated successfully"
    
    # Step 2: Convert HTML to PDF using wkhtmltopdf
    info "Converting HTML to PDF (this may take a moment)..."
    
    # Capture wkhtmltopdf output to check for errors
    local wkhtmltopdf_output
    wkhtmltopdf_output=$(wkhtmltopdf \
        --page-size A4 \
        --margin-top 0.75in \
        --margin-right 0.75in \
        --margin-bottom 0.75in \
        --margin-left 0.75in \
        --encoding UTF-8 \
        --enable-local-file-access \
        "file://$abs_html_intermediate" \
        "$abs_pdf_file" 2>&1) || {
        error "wkhtmltopdf failed to generate PDF"
        echo "$wkhtmltopdf_output" >&2
        rm -f "$abs_html_intermediate" "$html_template"
        return 1
    }
    
    # Check for image load failures in output
    if echo "$wkhtmltopdf_output" | grep -q "Failed to load"; then
        error "PDF generation failed: Image load error"
        echo "$wkhtmltopdf_output" | grep "Failed to load" | sed 's/^/  /' >&2
        rm -f "$abs_html_intermediate" "$html_template" "$abs_pdf_file"
        return 1
    fi
    
    success "PDF generated successfully: $pdf_file"
    
    # Cleanup intermediate files
    rm -f "$abs_html_intermediate" "$html_template"
    
    return 0
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
    
    # Generate TOC from source documentation
    generate_toc
    
    # Prepare output
    prepare_output_directory
    
    # Generate assets
    generate_css
    generate_cover_page
    
    # Compile documents
    compile_markdown
    
    # Convert to PDF
    convert_to_pdf
    
    # Summary
    echo ""
    echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  Documentation Compilation Complete!${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "Generated files:"
    echo "  📝 Markdown: $COMPILED_MD"
    echo "  📄 PDF: $COMPILED_PDF"
    echo ""
    echo "📋 TOC Source: $TOC_SOURCE"
    echo ""
    echo "Share the PDF with: ${CYAN}$COMPILED_PDF${NC}"
    echo ""
}

# Run main if executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi
