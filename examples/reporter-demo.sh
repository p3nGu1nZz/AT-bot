#!/bin/bash
# Demo script showcasing reporter.sh functionality
# This demonstrates the various console display functions available

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Source reporter library
source "$PROJECT_ROOT/lib/reporter.sh"

# Header
section "AT-bot Reporter Library Demo"

# Basic logging
subsection "Basic Logging Functions"
error "This is an error message"
success "This is a success message"
warning "This is a warning message"
info "This is an info message"
echo ""

# Enhanced logging with icons
subsection "Enhanced Logging with Icons"
log_info "Processing data..."
log_success "Data processed successfully"
log_error "Failed to connect to server"
log_warning "Deprecated API endpoint used"
log_skip "Test skipped due to missing dependencies"
echo ""

# Progress indicators
subsection "Progress Indicators"
progress "Downloading files..."
sleep 0.5
complete "Download complete"
step "1" "Initialize configuration"
step "2" "Connect to server"
step "3" "Process data"
echo ""

# Formatting
subsection "Key-Value Pairs"
kvpair "Name" "AT-bot"
kvpair "Version" "0.2.0"
kvpair "Status" "Active"
kvpair "Environment" "Production"
echo ""

# Lists
subsection "List Items"
list_item "First item in the list"
list_item "Second item in the list"
list_item "Third item in the list"
echo ""

subsection "Numbered Lists"
numbered_item 1 "Clone the repository"
numbered_item 2 "Run the installation script"
numbered_item 3 "Configure your credentials"
numbered_item 4 "Start using AT-bot"
echo ""

# Table
subsection "Table Display"
table_header "Component" "Status" "Version"
table_row "Core Library" "Active" "1.0.0"
table_row "CLI Tool" "Active" "0.2.0"
table_row "MCP Server" "Beta" "0.1.0"
echo ""

# Progress bar
subsection "Progress Bar"
for i in 0 20 40 60 80 100; do
    progress_bar $i 100 40
    sleep 0.1
done
echo ""

# Validation
subsection "Validation Functions"
validate "Dependencies installed" 0
validate "Configuration valid" 0
validate "Network connection" 1
validate "Remote server accessible" 1
echo ""

# Status indicators
subsection "Status Indicators"
echo -n "Service 1: "
status "enabled"
echo -n "Service 2: "
status "disabled"
echo -n "Service 3: "
status "pending"
echo ""

# Specialized reports
subsection "Specialized Reports"
dependency_report "bash" 0
dependency_report "curl" 0
dependency_report "imaginary-tool" 1
echo ""

command_report "make test" 0 "15"
command_report "make build" 1
echo ""

# Test summary
subsection "Test Summary Example"
test_summary 45 5 3
echo ""

# Boxed text
subsection "Boxed Text"
boxed "Important Message"
boxed "AT-bot Reporter Demo Complete"
echo ""

# Final message
log_success "Reporter library demonstration complete!"
echo ""
info "These functions are available in all AT-bot scripts and libraries"
echo ""
