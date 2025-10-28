#!/bin/bash
# AT-bot Dependency Setup Script
# Purpose: Check and install all required dependencies for AT-bot
# 
# This script ensures all system dependencies are available.
# It supports multiple Linux distributions and provides helpful
# installation instructions for missing dependencies.
#
# Usage:
#   source lib/setup.sh
#   setup_dependencies          # Check all dependencies
#   install_missing_deps        # Auto-install missing dependencies (requires sudo)

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

# Detect operating system
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        OS_VERSION=$VERSION_ID
    elif [ -f /etc/redhat-release ]; then
        OS="rhel"
        OS_VERSION=$(rpm -q --qf '%{VERSION}' centos-release || echo "unknown")
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        OS=$(echo "$DISTRIB_ID" | tr '[:upper:]' '[:lower:]')
        OS_VERSION=$DISTRIB_RELEASE
    elif command -v lsb_release >/dev/null 2>&1; then
        OS=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
        OS_VERSION=$(lsb_release -sr)
    else
        OS="unknown"
        OS_VERSION="unknown"
    fi
    
    # Detect macOS
    if [ "$(uname)" = "Darwin" ]; then
        OS="macos"
        OS_VERSION=$(sw_vers -productVersion)
    fi
    
    echo "$OS"
}

# Check if command exists
has_command() {
    command -v "$1" >/dev/null 2>&1
}

# Check single dependency
check_dependency() {
    local cmd="$1"
    local name="${2:-$cmd}"
    
    if has_command "$cmd"; then
        success "$name is installed"
        return 0
    else
        error "$name is not installed"
        return 1
    fi
}

# Core dependencies (required for AT-bot)
check_core_dependencies() {
    info "Checking core dependencies..."
    local missing=0
    
    check_dependency "bash" "Bash" || missing=$((missing + 1))
    check_dependency "curl" "curl" || missing=$((missing + 1))
    check_dependency "grep" "grep" || missing=$((missing + 1))
    check_dependency "sed" "sed" || missing=$((missing + 1))
    check_dependency "awk" "awk" || missing=$((missing + 1))
    check_dependency "openssl" "OpenSSL" || missing=$((missing + 1))
    
    return $missing
}

# Optional dependencies
check_optional_dependencies() {
    info "Checking optional dependencies..."
    local missing=0
    
    if ! has_command "pandoc"; then
        warning "pandoc is not installed (needed for 'make docs')"
        missing=$((missing + 1))
    else
        success "pandoc is installed"
    fi
    
    if ! has_command "jq"; then
        warning "jq is not installed (optional, useful for JSON processing)"
        missing=$((missing + 1))
    else
        success "jq is installed"
    fi
    
    if ! has_command "make"; then
        warning "make is not installed (optional, used in Makefile)"
        missing=$((missing + 1))
    else
        success "make is installed"
    fi
    
    return 0  # Optional deps don't cause failure
}

# Get package manager
get_package_manager() {
    local os="$1"
    
    case "$os" in
        ubuntu|debian)
            echo "apt-get"
            ;;
        fedora|rhel|centos)
            echo "dnf"
            ;;
        opensuse*)
            echo "zypper"
            ;;
        alpine)
            echo "apk"
            ;;
        arch)
            echo "pacman"
            ;;
        macos)
            echo "brew"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Get package name for dependency on given OS
get_package_name() {
    local pkg="$1"
    local os="$2"
    
    case "$pkg:$os" in
        # Bash
        bash:*)
            echo "bash"
            ;;
        # curl
        curl:*)
            echo "curl"
            ;;
        # grep
        grep:*)
            echo "grep"
            ;;
        # sed
        sed:ubuntu|sed:debian)
            echo "sed"
            ;;
        sed:fedora|sed:rhel|sed:centos)
            echo "sed"
            ;;
        sed:macos)
            echo "gnu-sed"
            ;;
        sed:*)
            echo "sed"
            ;;
        # awk
        awk:ubuntu|awk:debian)
            echo "gawk"
            ;;
        awk:macos)
            echo "gawk"
            ;;
        awk:*)
            echo "gawk"
            ;;
        # openssl
        openssl:*)
            echo "openssl"
            ;;
        # pandoc
        pandoc:ubuntu|pandoc:debian)
            echo "pandoc"
            ;;
        pandoc:fedora|pandoc:rhel|pandoc:centos)
            echo "pandoc"
            ;;
        pandoc:macos)
            echo "pandoc"
            ;;
        pandoc:alpine)
            echo "pandoc"
            ;;
        pandoc:*)
            echo "pandoc"
            ;;
        # jq
        jq:*)
            echo "jq"
            ;;
        # make
        make:ubuntu|make:debian)
            echo "make"
            ;;
        make:fedora|make:rhel|make:centos)
            echo "make"
            ;;
        make:macos)
            echo "make"
            ;;
        make:*)
            echo "make"
            ;;
        *)
            echo "$pkg"
            ;;
    esac
}

# Install packages using apt-get (Debian/Ubuntu)
install_with_apt() {
    info "Using apt-get to install missing dependencies..."
    
    if [ "$EUID" -ne 0 ]; then
        warning "Requires sudo for apt-get. Will prompt for password."
        sudo apt-get update
        sudo apt-get install -y "$@"
    else
        apt-get update
        apt-get install -y "$@"
    fi
}

# Install packages using dnf (Fedora/RHEL)
install_with_dnf() {
    info "Using dnf to install missing dependencies..."
    
    if [ "$EUID" -ne 0 ]; then
        warning "Requires sudo for dnf. Will prompt for password."
        sudo dnf install -y "$@"
    else
        dnf install -y "$@"
    fi
}

# Install packages using brew (macOS)
install_with_brew() {
    info "Using brew to install missing dependencies..."
    
    if ! has_command "brew"; then
        error "Homebrew not installed. Please install from https://brew.sh"
        return 1
    fi
    
    brew install "$@"
}

# Install packages using apk (Alpine)
install_with_apk() {
    info "Using apk to install missing dependencies..."
    
    if [ "$EUID" -ne 0 ]; then
        warning "Requires sudo for apk. Will prompt for password."
        sudo apk add "$@"
    else
        apk add "$@"
    fi
}

# Main setup and validation function
setup_dependencies() {
    info "AT-bot Dependency Check"
    info "======================="
    info ""
    
    local os
    os=$(detect_os)
    info "Detected OS: $os"
    info ""
    
    # Check core dependencies
    if ! check_core_dependencies; then
        warning "Some core dependencies are missing"
        return 1
    fi
    
    info ""
    
    # Check optional dependencies
    check_optional_dependencies
    
    info ""
    success "Dependency check complete!"
    return 0
}

# Auto-install missing dependencies
install_missing_deps() {
    local os
    os=$(detect_os)
    
    info "Installing missing dependencies for: $os"
    info ""
    
    local packages=()
    
    # Collect missing core packages
    if ! has_command "curl"; then
        packages+=("$(get_package_name curl "$os")")
    fi
    
    if ! has_command "grep"; then
        packages+=("$(get_package_name grep "$os")")
    fi
    
    if ! has_command "sed"; then
        packages+=("$(get_package_name sed "$os")")
    fi
    
    if ! has_command "awk"; then
        packages+=("$(get_package_name awk "$os")")
    fi
    
    if ! has_command "openssl"; then
        packages+=("$(get_package_name openssl "$os")")
    fi
    
    # Check for optional packages to install
    local optional_packages=()
    if ! has_command "pandoc"; then
        optional_packages+=("$(get_package_name pandoc "$os")")
    fi
    
    if ! has_command "make"; then
        optional_packages+=("$(get_package_name make "$os")")
    fi
    
    if [ ${#packages[@]} -eq 0 ] && [ ${#optional_packages[@]} -eq 0 ]; then
        success "All dependencies already installed!"
        return 0
    fi
    
    # Display what will be installed
    if [ ${#packages[@]} -gt 0 ]; then
        info "Core dependencies to install: ${packages[*]}"
    fi
    
    if [ ${#optional_packages[@]} -gt 0 ]; then
        info "Optional dependencies to install: ${optional_packages[*]}"
    fi
    
    info ""
    
    # Install core packages
    if [ ${#packages[@]} -gt 0 ]; then
        case "$os" in
            ubuntu|debian)
                install_with_apt "${packages[@]}" || return 1
                ;;
            fedora|rhel|centos)
                install_with_dnf "${packages[@]}" || return 1
                ;;
            macos)
                install_with_brew "${packages[@]}" || return 1
                ;;
            alpine)
                install_with_apk "${packages[@]}" || return 1
                ;;
            *)
                error "Unsupported OS: $os"
                error "Please install dependencies manually:"
                printf "%s\n" "${packages[@]}"
                return 1
                ;;
        esac
    fi
    
    # Optionally install optional packages
    if [ ${#optional_packages[@]} -gt 0 ]; then
        info ""
        read -p "Install optional dependencies? (y/n) " -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            case "$os" in
                ubuntu|debian)
                    install_with_apt "${optional_packages[@]}" || warning "Failed to install some optional packages"
                    ;;
                fedora|rhel|centos)
                    install_with_dnf "${optional_packages[@]}" || warning "Failed to install some optional packages"
                    ;;
                macos)
                    install_with_brew "${optional_packages[@]}" || warning "Failed to install some optional packages"
                    ;;
                alpine)
                    install_with_apk "${optional_packages[@]}" || warning "Failed to install some optional packages"
                    ;;
            esac
        fi
    fi
    
    info ""
    success "Dependency installation complete!"
    return 0
}

# Export functions if this script is sourced
export -f setup_dependencies
export -f install_missing_deps
export -f has_command
export -f detect_os

# Run setup if script is executed directly (not sourced)
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    # Check if install flag provided
    if [ "${1:-}" = "install" ]; then
        install_missing_deps "$@"
    else
        setup_dependencies "$@"
    fi
fi
