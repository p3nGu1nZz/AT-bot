# Documentation Compilation Guide

This guide explains how to use AT-bot's documentation compilation system to generate a comprehensive, professionally formatted PDF containing all project documentation.

## Overview

The documentation compiler (`lib/doc.sh`) provides a streamlined workflow to:
- Compile all markdown files into a single document
- Generate a table of contents automatically
- Convert to HTML with custom styling
- Export as a professionally formatted PDF
- Maintain logical document ordering
- Avoid duplicate content

## Quick Start

Generate complete documentation in three ways:

### Method 1: Using Make (Recommended)
```bash
make docs
```

### Method 2: Direct Script Execution
```bash
./bin/at-bot-docs
```

### Method 3: Library Function
```bash
source lib/doc.sh
main
```

## What Gets Generated

Three comprehensive documentation files are created in `dist/docs/`:

1. **AT-bot_Complete_Documentation.md** (361KB+)
   - All markdown files compiled into one
   - Logical document ordering
   - No duplicates

2. **AT-bot_Complete_Documentation.html**
   - Styled HTML with custom CSS
   - Clickable table of contents
   - Syntax-highlighted code blocks

3. **AT-bot_Complete_Documentation.pdf**
   - Professional PDF format
   - Auto-generated table of contents
   - Perfect for sharing and offline use

**Current Statistics:**
- **Lines**: ~13,000+
- **Words**: ~45,000+
- **Size**: 361KB+ (markdown), varies for HTML/PDF
- **Documents**: 30+ files combined

## Requirements

### Required Dependencies
- **pandoc**: Universal document converter
- **XeLaTeX**: PDF rendering engine (part of TeX Live)

### Installation

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install pandoc texlive-xetex texlive-fonts-recommended
```

**macOS:**
```bash
brew install pandoc basictex
# After installation, update PATH:
eval "$(/usr/libexec/path_helper)"
```

**Other Systems:**
Visit [Pandoc Installation Guide](https://pandoc.org/installing.html)

## Output Files

The compilation process generates three files in `dist/docs/`:

1. **AT-bot_Complete_Documentation.md** - Combined markdown source
2. **AT-bot_Complete_Documentation.html** - Styled HTML version
3. **AT-bot_Complete_Documentation.pdf** - Final PDF output (recommended for sharing)

Additionally created:
- **cover.md** - Generated cover page
- **documentation.css** - Custom styling for HTML/PDF

## Key Features

✅ **Smart Ordering** - Documents organized logically  
✅ **Duplicate Prevention** - Each file included once  
✅ **Auto TOC** - Table of contents generated automatically  
✅ **Professional Styling** - Custom CSS for clean presentation  
✅ **Syntax Highlighting** - Code blocks properly formatted  
✅ **Page Breaks** - Logical document separation  
✅ **Coverage Detection** - Finds all markdown files

## Document Organization

### Strategic Document Order

The compiler uses a carefully designed document order that reflects the logical flow of information:

1. **Introduction**
   - README.md - Project overview

2. **Strategic Documents**
   - PLAN.md - Development roadmap
   - AGENTS.md - AI integration patterns

3. **Standards & Guidelines**
   - STYLE.md - Code conventions
   - SECURITY.md - Security practices
   - CONTRIBUTING.md - Contribution guidelines

4. **Project Management**
   - TODO.md - Task tracking

5. **Technical Documentation**
   - Architecture, quickstart, configuration guides

6. **Feature Documentation**
   - Encryption, debugging, testing, packaging

7. **MCP Server Documentation**
   - MCP quickstart, tools, integration

8. **Progress Tracking**
   - Project dashboard, milestone reports

9. **Session Summaries**
   - Development session notes (most recent first)

### Customizing Document Order

Edit the `DOC_ORDER` array in `lib/doc.sh`:

```bash
declare -a DOC_ORDER=(
    "README.md"
    "PLAN.md"
    # Add your custom order here...
)
```

## Features

### Automatic Table of Contents

The PDF includes an automatically generated table of contents with:
- Three levels of heading depth
- Clickable links to sections
- Page numbers for easy navigation

### Professional Styling

Custom CSS provides:
- Clean, readable typography
- Syntax-highlighted code blocks
- Proper page breaks between sections
- Formatted tables and lists
- Consistent heading hierarchy

### Duplicate Prevention

The compiler tracks processed files to ensure:
- No document appears twice
- Canonical paths are used
- Symlinks are properly handled

### Coverage Detection

The system identifies:
- All markdown files in the project
- Files not included in the order list
- Warns about potentially missing documentation

## Customization

### Modifying CSS Styles

Edit the `generate_css()` function in `lib/doc.sh` to customize:
- Colors and fonts
- Spacing and margins
- Code block styling
- Table formatting

Example color customization:
```css
:root {
    --primary-color: #0066cc;    /* Main headings */
    --secondary-color: #004080;  /* Subheadings */
    --accent-color: #00cc66;     /* Highlights */
}
```

### Custom Cover Page

Modify the `generate_cover_page()` function to update:
- Title and subtitle
- Author information
- Version details
- Project metadata

### Excluding Files

Add patterns to the exclusion list in `compile_markdown()`:

```bash
case "$relative_path" in
    dist/*|node_modules/*|.git/*|your_pattern/*)
        # Skip these files
        ;;
esac
```

## Advanced Usage

### Generate HTML Only

To skip PDF generation and only create HTML:

```bash
source lib/doc.sh
check_dependencies
prepare_output_directory
generate_css
generate_cover_page
compile_markdown
convert_to_html
```

### Custom Output Directory

Set a custom output location:

```bash
export OUTPUT_DIR="/path/to/custom/output"
./bin/at-bot-docs
```

### Processing Specific Files

Create a custom order list and call the processing function:

```bash
source lib/doc.sh
declare -a CUSTOM_ORDER=("README.md" "PLAN.md")
# Process your custom list...
```

## Troubleshooting

### Error: "pandoc is required but not installed"

**Solution**: Install pandoc using your package manager (see Requirements section above).

### Error: "Failed to generate PDF"

**Cause**: Missing XeLaTeX/TeX Live installation.

**Solution**: Install the full TeX Live distribution:
```bash
# Ubuntu/Debian
sudo apt-get install texlive-xetex texlive-fonts-recommended texlive-latex-extra

# macOS
brew install --cask mactex
```

### Warning: "Found unordered document"

**Meaning**: A markdown file exists but isn't in the `DOC_ORDER` list.

**Solution**: Either add it to the order list or ignore if it's intentional (e.g., draft files).

### PDF Too Large

**Cause**: Many high-resolution images or extensive content.

**Solution**: Consider:
- Optimizing image sizes
- Splitting into multiple PDFs
- Using HTML version instead

## Best Practices

### 1. Regular Regeneration

Regenerate documentation after:
- Major feature additions
- Significant documentation updates
- Before releases or presentations

### 2. Version Control

Commit the generated PDF for:
- Release tags
- Major milestones
- Long-term archival

Add to `.gitignore` for:
- Intermediate builds
- Development iterations

### 3. Quality Checks

After generation, verify:
- Table of contents is complete
- All sections are present
- Code blocks are readable
- Links work correctly

### 4. Sharing

The PDF is perfect for:
- Onboarding new contributors
- Project presentations
- Stakeholder reviews
- Offline reference
- Archive distribution

## Integration with Workflow

### Pre-Release Checklist

```bash
# Update all documentation
git pull origin main

# Generate fresh documentation
make docs

# Review the output
open dist/docs/AT-bot_Complete_Documentation.pdf

# Commit if satisfied
git add dist/docs/AT-bot_Complete_Documentation.pdf
git commit -m "docs: update complete documentation for v0.x.0 release"
```

### CI/CD Integration

Add to your pipeline:

```yaml
- name: Generate Documentation
  run: make docs
  
- name: Archive Documentation
  uses: actions/upload-artifact@v3
  with:
    name: documentation-pdf
    path: dist/docs/*.pdf
```

## File Structure

```
AT-bot/
├── lib/
│   └── doc.sh              # Core compilation script
├── bin/
│   └── at-bot-docs         # Convenient wrapper
├── dist/
│   └── docs/               # Generated output
│       ├── AT-bot_Complete_Documentation.md
│       ├── AT-bot_Complete_Documentation.html
│       ├── AT-bot_Complete_Documentation.pdf
│       ├── documentation.css
│       └── cover.md
└── doc/
    └── DOCUMENTATION_GENERATION.md  # This file
```

## FAQ

**Q: Can I customize which files are included?**  
A: Yes, edit the `DOC_ORDER` array in `lib/doc.sh`.

**Q: How do I change the PDF styling?**  
A: Modify the `generate_css()` function or pandoc variables in `convert_to_pdf()`.

**Q: Can I generate just specific sections?**  
A: Yes, create a custom script that sources `lib/doc.sh` and processes only desired files.

**Q: Why is my PDF missing images?**  
A: Ensure image paths are relative to the project root or use absolute URLs.

**Q: Can I add custom metadata?**  
A: Yes, edit the YAML frontmatter in `generate_cover_page()`.

## Contributing

Improvements to the documentation system are welcome! Consider:
- Additional output formats (EPUB, RTF)
- Enhanced styling options
- Better syntax highlighting
- Automated table generation
- Interactive HTML features

See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines.

## Resources

- [Pandoc Manual](https://pandoc.org/MANUAL.html)
- [Markdown Guide](https://www.markdownguide.org/)
- [LaTeX Documentation](https://www.latex-project.org/help/documentation/)
- [CSS for Print](https://www.smashingmagazine.com/2015/01/designing-for-print-with-css/)

---

*Last updated: October 28, 2025*
