#!/bin/bash
# AT-bot Console Display and Reporting Library
# Provides centralized console output, logging, and reporting functions
# for use across all scripts and library modules

# ============================================================================
# Color Definitions and TTY Detection
# ============================================================================

# Auto-detect if output is to a terminal and enable colors accordingly
# Only define if not already defined (to support multiple sourcing)
if [ -z "${AT_BOT_COLORS_DEFINED:-}" ]; then
    if [ -t 1 ]; then
        # Terminal output - enable colors
        RED='\033[0;31m'
        GREEN='\033[0;32m'
        YELLOW='\033[1;33m'
        BLUE='\033[0;34m'
        CYAN='\033[0;36m'
        MAGENTA='\033[0;35m'
        WHITE='\033[1;37m'
        BOLD='\033[1m'
        DIM='\033[2m'
        NC='\033[0m'  # No Color / Reset
    else
        # Non-terminal output - disable colors
        RED=''
        GREEN=''
        YELLOW=''
        BLUE=''
        CYAN=''
        MAGENTA=''
        WHITE=''
        BOLD=''
        DIM=''
        NC=''
    fi
    
    # Mark that colors have been defined
    AT_BOT_COLORS_DEFINED=1
fi

# ============================================================================
# Basic Logging Functions
# ============================================================================

# Print error message to stderr
# Usage: error "message"
error() {
    echo -e "${RED}Error:${NC} $*" >&2
}

# Print success message
# Usage: success "message"
success() {
    echo -e "${GREEN}$*${NC}"
}

# Print warning message to stderr
# Usage: warning "message"
warning() {
    echo -e "${YELLOW}Warning:${NC} $*" >&2
}

# Print info message
# Usage: info "message"
info() {
    echo -e "${BLUE}$*${NC}"
}

# Print debug message (respects DEBUG environment variable)
# Usage: debug "message"
debug() {
    if [ "${DEBUG:-0}" = "1" ]; then
        echo -e "${DIM}[DEBUG]${NC} $*" >&2
    fi
}

# ============================================================================
# Enhanced Logging Functions with Icons
# ============================================================================

# Print info with icon
# Usage: log_info "message"
log_info() {
    echo -e "${BLUE}ℹ${NC} $*"
}

# Print success with icon
# Usage: log_success "message"
log_success() {
    echo -e "${GREEN}✓${NC} $*"
}

# Print error with icon
# Usage: log_error "message"
log_error() {
    echo -e "${RED}✗${NC} $*" >&2
}

# Print warning with icon
# Usage: log_warning "message"
log_warning() {
    echo -e "${YELLOW}⚠${NC} $*" >&2
}

# Print skip/ignore message with icon
# Usage: log_skip "message"
log_skip() {
    echo -e "${YELLOW}⊘${NC} $*"
}

# ============================================================================
# Progress and Status Functions
# ============================================================================

# Print progress message
# Usage: progress "Doing something..."
progress() {
    echo -e "${CYAN}→${NC} $*"
}

# Print completion message
# Usage: complete "Task finished"
complete() {
    echo -e "${GREEN}✓${NC} $*"
}

# Print step header
# Usage: step "Step 1" "Description"
step() {
    local step_num="$1"
    local step_desc="$2"
    echo -e "${BOLD}${step_num}${NC} ${step_desc}"
}

# ============================================================================
# Header and Section Formatting
# ============================================================================

# Print a simple header
# Usage: header "Title"
header() {
    local title="$1"
    echo ""
    echo -e "${BLUE}${title}${NC}"
    echo -e "${BLUE}$(printf '=%.0s' $(seq 1 ${#title}))${NC}"
    echo ""
}

# Print a section header with decorative border
# Usage: section "Section Title"
section() {
    local title="$1"
    local width=56
    echo ""
    echo -e "${BLUE}$(printf '═%.0s' $(seq 1 $width))${NC}"
    echo -e "${BLUE}${title}${NC}"
    echo -e "${BLUE}$(printf '═%.0s' $(seq 1 $width))${NC}"
    echo ""
}

# Print a subsection header
# Usage: subsection "Subsection Title"
subsection() {
    local title="$1"
    echo ""
    echo -e "${CYAN}${title}${NC}"
    echo -e "${CYAN}$(printf '-%.0s' $(seq 1 ${#title}))${NC}"
    echo ""
}

# Print a simple divider
# Usage: divider
divider() {
    echo -e "${DIM}$(printf '─%.0s' $(seq 1 56))${NC}"
}

# ============================================================================
# Summary and Report Functions
# ============================================================================

# Print test summary
# Usage: test_summary <passed> <failed> <skipped>
test_summary() {
    local passed="$1"
    local failed="$2"
    local skipped="${3:-0}"
    local total=$((passed + failed))
    
    section "Test Summary"
    
    local pass_percent=0
    if [ "$total" -gt 0 ]; then
        pass_percent=$((passed * 100 / total))
    fi
    
    echo "  Passed:       ${GREEN}$passed${NC}/$total"
    echo "  Failed:       ${RED}$failed${NC}/$total"
    [ "$skipped" -gt 0 ] && echo "  Skipped:      ${YELLOW}$skipped${NC}"
    echo "  Success Rate: ${pass_percent}%"
    echo ""
}

# Print build summary
# Usage: build_summary <status> <time> [output_file]
build_summary() {
    local status="$1"
    local build_time="$2"
    local output_file="${3:-}"
    
    section "Build Summary"
    
    if [ "$status" = "success" ]; then
        echo -e "  Status:  ${GREEN}Success${NC}"
    else
        echo -e "  Status:  ${RED}Failed${NC}"
    fi
    
    echo "  Time:    ${build_time}"
    
    if [ -n "$output_file" ]; then
        echo "  Output:  $output_file"
    fi
    echo ""
}

# Print key-value pair in consistent format
# Usage: kvpair "Key" "value"
kvpair() {
    local key="$1"
    local value="$2"
    printf "  %-20s ${CYAN}%s${NC}\n" "$key:" "$value"
}

# Print list item
# Usage: list_item "item text"
list_item() {
    echo -e "  ${CYAN}•${NC} $*"
}

# Print numbered list item
# Usage: numbered_item <number> "item text"
numbered_item() {
    local number="$1"
    shift
    printf "  ${GREEN}%2d.${NC} %s\n" "$number" "$*"
}

# ============================================================================
# Error Handling and Suggestions
# ============================================================================

# Print error with helpful suggestion
# Usage: error_with_suggestion <code> "error message" "suggestion"
error_with_suggestion() {
    local code="$1"
    local message="$2"
    local suggestion="$3"
    
    error "$message"
    [ -n "$suggestion" ] && echo -e "${YELLOW}💡 Suggestion:${NC} $suggestion" >&2
    return "$code"
}

# ============================================================================
# Table Formatting
# ============================================================================

# Print table header
# Usage: table_header "Column1" "Column2" "Column3"
table_header() {
    echo ""
    echo -e "${BOLD}$(printf "  %-20s %-20s %-20s\n" "$@")${NC}"
    divider
}

# Print table row
# Usage: table_row "value1" "value2" "value3"
table_row() {
    printf "  %-20s %-20s %-20s\n" "$@"
}

# ============================================================================
# Progress Bar (Simple ASCII)
# ============================================================================

# Show a simple progress bar
# Usage: progress_bar <current> <total> [width]
progress_bar() {
    local current="$1"
    local total="$2"
    local width="${3:-40}"
    
    local percent=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    printf "\r${CYAN}["
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "] %3d%%${NC}" "$percent"
    
    [ "$current" -eq "$total" ] && echo ""
}

# ============================================================================
# Validation and Status
# ============================================================================

# Print validation result
# Usage: validate "Check description" <result_code>
validate() {
    local description="$1"
    local result="$2"
    
    if [ "$result" -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $description"
        return 0
    else
        echo -e "${RED}✗${NC} $description"
        return 1
    fi
}

# Print status indicator
# Usage: status "enabled" or status "disabled"
status() {
    local state="$1"
    
    case "$state" in
        enabled|active|on|yes|true)
            echo -e "${GREEN}●${NC} enabled"
            ;;
        disabled|inactive|off|no|false)
            echo -e "${RED}○${NC} disabled"
            ;;
        *)
            echo -e "${YELLOW}◐${NC} $state"
            ;;
    esac
}

# ============================================================================
# Formatting Utilities
# ============================================================================

# Print text in a box
# Usage: boxed "Text to display"
boxed() {
    local text="$1"
    local len=${#text}
    local border=$(printf '─%.0s' $(seq 1 $((len + 4))))
    
    echo -e "${BLUE}┌${border}┐${NC}"
    echo -e "${BLUE}│${NC}  ${text}  ${BLUE}│${NC}"
    echo -e "${BLUE}└${border}┘${NC}"
}

# Print centered text
# Usage: centered "Text" [width]
centered() {
    local text="$1"
    local width="${2:-80}"
    local len=${#text}
    local padding=$(( (width - len) / 2 ))
    
    printf "%${padding}s%s\n" "" "$text"
}

# ============================================================================
# Quiet Mode Support
# ============================================================================

# Conditional output based on QUIET flag
# Usage: output_if_not_quiet "message"
output_if_not_quiet() {
    [ "${QUIET:-false}" = "false" ] && echo "$@"
}

# ============================================================================
# Specialized Report Functions
# ============================================================================

# Print dependency check report
# Usage: dependency_report "dep_name" <status_code>
dependency_report() {
    local dep_name="$1"
    local status="$2"
    
    if [ "$status" -eq 0 ]; then
        log_success "$dep_name is installed"
        return 0
    else
        log_error "$dep_name is not installed"
        return 1
    fi
}

# Print file operation report
# Usage: file_operation_report "operation" "filename" <status_code>
file_operation_report() {
    local operation="$1"
    local filename="$2"
    local status="$3"
    
    if [ "$status" -eq 0 ]; then
        log_success "$operation: $filename"
        return 0
    else
        log_error "$operation failed: $filename"
        return 1
    fi
}

# Print command execution report
# Usage: command_report "command_name" <exit_code> [duration]
command_report() {
    local command="$1"
    local exit_code="$2"
    local duration="${3:-}"
    
    if [ "$exit_code" -eq 0 ]; then
        if [ -n "$duration" ]; then
            log_success "$command completed in ${duration}s"
        else
            log_success "$command completed"
        fi
        return 0
    else
        log_error "$command failed with exit code $exit_code"
        return 1
    fi
}

# ============================================================================
# Export Functions (Optional)
# ============================================================================

# If this script is sourced, all functions are available
# No explicit export needed in bash, but we document them here for clarity

# Core logging: error, success, warning, info, debug
# Enhanced logging: log_info, log_success, log_error, log_warning, log_skip
# Progress: progress, complete, step
# Headers: header, section, subsection, divider
# Summaries: test_summary, build_summary
# Formatting: kvpair, list_item, numbered_item, boxed, centered
# Tables: table_header, table_row
# Validation: validate, status, dependency_report, file_operation_report, command_report
# Utilities: progress_bar, error_with_suggestion
