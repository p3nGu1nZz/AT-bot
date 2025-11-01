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
    # Check color output preference
    COLOR_MODE="${ATP_COLOR:-auto}"
    
    case "$COLOR_MODE" in
        always)
            # Force colors on
            COLORS_ENABLED=1
            ;;
        never)
            # Force colors off
            COLORS_ENABLED=0
            ;;
        auto|*)
            # Auto-detect terminal
            if [ -t 1 ]; then
                COLORS_ENABLED=1
            else
                COLORS_ENABLED=0
            fi
            ;;
    esac
    
    if [ "$COLORS_ENABLED" -eq 1 ]; then
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
# Verbosity Control
# ============================================================================

# Verbosity levels:
# 0 = quiet (errors only)
# 1 = normal (errors, warnings, success)
# 2 = verbose (errors, warnings, success, info, debug)
ATP_VERBOSITY="${ATP_VERBOSITY:-1}"

# Check if quiet mode is enabled
is_quiet() {
    [ "$ATP_VERBOSITY" -eq 0 ]
}

# Check if verbose mode is enabled
is_verbose() {
    [ "$ATP_VERBOSITY" -ge 2 ]
}

# ============================================================================
# Basic Logging Functions
# ============================================================================

# Print error message to stderr (always shown)
# Usage: error "message"
error() {
    echo -e "${RED}Error:${NC} $*" >&2
}

# Print success message (hidden in quiet mode)
# Usage: success "message"
success() {
    if ! is_quiet; then
        echo -e "${GREEN}$*${NC}"
    fi
}

# Print warning message (hidden in quiet mode)
# Usage: warning "message"
warning() {
    if ! is_quiet; then
        echo -e "${YELLOW}Warning:${NC} $*" >&2
    fi
}

# Print info message (only in verbose mode)
# Usage: info "message"
info() {
    if is_verbose; then
        echo -e "${BLUE}Info:${NC} $*"
    fi
}

# Print debug message (only in verbose mode)
# Usage: debug "message"
debug() {
    if is_verbose; then
        echo -e "${DIM}Debug:${NC} $*" >&2
    fi
}

# ============================================================================
# Progress Indicators
# ============================================================================

# Show a spinner for long-running operations
# Usage: show_spinner "message" & SPINNER_PID=$!; do_work; stop_spinner $SPINNER_PID
show_spinner() {
    local message="$1"
    local spinstr='|/-\'
    
    # Don't show spinner in quiet mode or non-terminal
    if is_quiet || [ ! -t 1 ]; then
        return 0
    fi
    
    while true; do
        local temp=${spinstr#?}
        printf " [%c]  %s\r" "$spinstr" "$message"
        local spinstr=$temp${spinstr%"$temp"}
        sleep 0.1
    done
}

# Stop a spinner
# Usage: stop_spinner $SPINNER_PID "Done message"
stop_spinner() {
    local pid="$1"
    local message="${2:-Done}"
    
    if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
        kill "$pid" 2>/dev/null
        wait "$pid" 2>/dev/null
    fi
    
    if ! is_quiet && [ -t 1 ]; then
        printf "\r\033[K"  # Clear line
        success "$message"
    fi
}

# Show progress bar
# Usage: show_progress current total "message"
show_progress() {
    local current="$1"
    local total="$2"
    local message="${3:-Processing}"
    
    # Don't show progress in quiet mode or non-terminal
    if is_quiet || [ ! -t 1 ]; then
        return 0
    fi
    
    local percent=$((current * 100 / total))
    local filled=$((percent / 2))
    local empty=$((50 - filled))
    
    printf "\r${message}: ["
    printf "%${filled}s" | tr ' ' '='
    printf "%${empty}s" | tr ' ' ' '
    printf "] %3d%%" "$percent"
    
    if [ "$current" -eq "$total" ]; then
        printf "\n"
    fi
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
    local len=${#title}
    echo ""
    echo -e "${CYAN}${title}${NC}"
    echo -e "${CYAN}$(printf '%*s' "$len" | tr ' ' '-')${NC}"
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
    
    if [ "$current" -eq "$total" ]; then
        echo ""
    fi
    
    return 0
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
