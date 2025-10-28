#!/bin/bash
# AT-bot Encryption Module
# Provides secure encryption/decryption functionality for all AT-bot components
#
# Security Features:
# - AES-256-CBC encryption
# - PBKDF2 key derivation with salt
# - Secure memory handling
# - Zero plaintext credential exposure
# - Support for both random keys and passphrase-based encryption

# Configuration
CRYPT_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/at-bot"
ENCRYPTION_KEY_FILE="$CRYPT_DIR/.key"
SALT_FILE="$CRYPT_DIR/.salt"

# Encryption constants
PBKDF2_ITERATIONS=100000  # High iteration count for security
KEY_LENGTH=32              # 256 bits for AES-256
SALT_LENGTH=32             # 256 bits salt

# Color output for error messages (if not already defined)
if [ -z "$RED" ]; then
    if [ -t 1 ]; then
        RED='\033[0;31m'
        GREEN='\033[0;32m'
        YELLOW='\033[1;33m'
        NC='\033[0m'
    else
        RED=''
        GREEN=''
        YELLOW=''
        NC=''
    fi
fi

# Output functions (if not already defined)
if ! type error >/dev/null 2>&1; then
    error() {
        echo -e "${RED}Error:${NC} $*" >&2
    }
fi

if ! type debug >/dev/null 2>&1; then
    debug() {
        if [ "${DEBUG:-0}" = "1" ]; then
            echo -e "${YELLOW}[DEBUG]${NC} $*" >&2
        fi
    }
fi

if ! type warning >/dev/null 2>&1; then
    warning() {
        echo -e "${YELLOW}Warning:${NC} $*" >&2
    }
fi

# Check if OpenSSL is available
#
# Returns:
#   0 - OpenSSL available
#   1 - OpenSSL not found
check_openssl() {
    if ! command -v openssl >/dev/null 2>&1; then
        error "OpenSSL not found. Encryption requires OpenSSL."
        error "Install: sudo apt-get install openssl"
        return 1
    fi
    return 0
}

# Generate or retrieve encryption salt
# Salt is used with PBKDF2 for key derivation
#
# Returns:
#   Prints salt (hex encoded) to stdout
generate_or_get_salt() {
    if [ -f "$SALT_FILE" ]; then
        cat "$SALT_FILE"
    else
        # Generate new salt using system entropy
        local salt
        salt=$(openssl rand -hex "$SALT_LENGTH")
        
        # Create config directory if needed
        mkdir -p "$CRYPT_DIR"
        
        # Save salt with strict permissions
        echo "$salt" > "$SALT_FILE"
        chmod 600 "$SALT_FILE"
        
        debug "Generated new encryption salt"
        echo "$salt"
    fi
}

# Generate or retrieve encryption key
# Uses random key generation for maximum security
#
# Returns:
#   Prints key to stdout
generate_or_get_key() {
    if [ -f "$ENCRYPTION_KEY_FILE" ]; then
        cat "$ENCRYPTION_KEY_FILE"
    else
        # Generate new encryption key using system entropy
        local key
        key=$(openssl rand -hex "$KEY_LENGTH")
        
        # Create config directory if needed
        mkdir -p "$CRYPT_DIR"
        
        # Save key with strict permissions
        echo "$key" > "$ENCRYPTION_KEY_FILE"
        chmod 600 "$ENCRYPTION_KEY_FILE"
        
        debug "Generated new encryption key"
        echo "$key"
    fi
}

# Derive encryption key from passphrase using PBKDF2
# This is more secure than using password directly
#
# Arguments:
#   $1 - passphrase
#   $2 - optional salt (hex encoded, generates if not provided)
#
# Returns:
#   Prints derived key (hex encoded) to stdout
derive_key_from_passphrase() {
    local passphrase="$1"
    local salt="${2:-}"
    
    if [ -z "$passphrase" ]; then
        error "Passphrase required for key derivation"
        return 1
    fi
    
    check_openssl || return 1
    
    # Get or generate salt
    if [ -z "$salt" ]; then
        salt=$(generate_or_get_salt)
    fi
    
    # Use PBKDF2 (Password-Based Key Derivation Function 2)
    # High iteration count makes brute force attacks very expensive
    # Use openssl pkcs12 for proper PBKDF2 key derivation
    local derived_key
    derived_key=$(echo -n "$passphrase" | \
        openssl enc -aes-256-cbc -P -S "$salt" -pbkdf2 -iter "$PBKDF2_ITERATIONS" -pass stdin 2>/dev/null | \
        grep "key=" | cut -d'=' -f2)
    
    if [ -z "$derived_key" ]; then
        error "Key derivation failed"
        return 1
    fi
    
    echo "$derived_key"
}

# Encrypt data using AES-256-CBC
# Uses PBKDF2 for key derivation from password
#
# Arguments:
#   $1 - plaintext data
#   $2 - optional password (uses stored key if not provided)
#
# Returns:
#   Encrypted data (base64 encoded) to stdout
encrypt_data() {
    local plaintext="$1"
    local password="${2:-}"
    
    if [ -z "$plaintext" ]; then
        error "Plaintext data required for encryption"
        return 1
    fi
    
    check_openssl || return 1
    
    # Use provided password or stored key
    local key
    if [ -n "$password" ]; then
        key="$password"
    else
        key=$(generate_or_get_key)
    fi
    
    # Encrypt using AES-256-CBC with salt and PBKDF2
    local encrypted
    encrypted=$(echo "$plaintext" | \
        openssl enc -aes-256-cbc -a -salt -pbkdf2 -iter "$PBKDF2_ITERATIONS" -pass pass:"$key" 2>/dev/null)
    
    if [ -z "$encrypted" ]; then
        error "Encryption failed"
        return 1
    fi
    
    echo "$encrypted"
}

# Decrypt data using AES-256-CBC
# Uses PBKDF2 for key derivation from password
#
# Arguments:
#   $1 - encrypted data (base64 encoded)
#   $2 - optional password (uses stored key if not provided)
#
# Returns:
#   Decrypted plaintext to stdout
decrypt_data() {
    local encrypted="$1"
    local password="${2:-}"
    
    if [ -z "$encrypted" ]; then
        error "Encrypted data required for decryption"
        return 1
    fi
    
    check_openssl || return 1
    
    # Use provided password or stored key
    local key
    if [ -n "$password" ]; then
        key="$password"
    else
        key=$(generate_or_get_key)
    fi
    
    # Decrypt using AES-256-CBC
    local decrypted
    decrypted=$(echo "$encrypted" | \
        openssl enc -aes-256-cbc -d -a -pbkdf2 -iter "$PBKDF2_ITERATIONS" -pass pass:"$key" 2>/dev/null)
    
    if [ $? -ne 0 ]; then
        error "Decryption failed - invalid key or corrupted data"
        return 1
    fi
    
    echo "$decrypted"
}

# Encrypt a file in-place
# Creates backup before encryption
#
# Arguments:
#   $1 - file path
#   $2 - optional password
#
# Returns:
#   0 - Success
#   1 - Failure
encrypt_file() {
    local filepath="$1"
    local password="${2:-}"
    
    if [ ! -f "$filepath" ]; then
        error "File not found: $filepath"
        return 1
    fi
    
    check_openssl || return 1
    
    # Create backup
    local backup_file="${filepath}.backup"
    cp "$filepath" "$backup_file"
    debug "Created backup: $backup_file"
    
    # Read file content
    local content
    content=$(cat "$filepath")
    
    # Encrypt content
    local encrypted
    encrypted=$(encrypt_data "$content" "$password")
    
    if [ $? -ne 0 ]; then
        error "Failed to encrypt file: $filepath"
        return 1
    fi
    
    # Write encrypted content
    echo "$encrypted" > "$filepath"
    chmod 600 "$filepath"
    
    debug "Encrypted file: $filepath"
    return 0
}

# Decrypt a file in-place
# Looks for backup if decryption fails
#
# Arguments:
#   $1 - file path
#   $2 - optional password
#
# Returns:
#   0 - Success
#   1 - Failure
decrypt_file() {
    local filepath="$1"
    local password="${2:-}"
    
    if [ ! -f "$filepath" ]; then
        error "File not found: $filepath"
        return 1
    fi
    
    check_openssl || return 1
    
    # Read encrypted content
    local encrypted
    encrypted=$(cat "$filepath")
    
    # Decrypt content
    local decrypted
    decrypted=$(decrypt_data "$encrypted" "$password")
    
    if [ $? -ne 0 ]; then
        error "Failed to decrypt file: $filepath"
        # Check for backup
        if [ -f "${filepath}.backup" ]; then
            warning "Backup available: ${filepath}.backup"
        fi
        return 1
    fi
    
    # Write decrypted content
    echo "$decrypted" > "$filepath"
    
    debug "Decrypted file: $filepath"
    return 0
}

# Securely erase sensitive data from memory
# Overwrites variable with random data before unsetting
#
# Arguments:
#   $1 - variable name
secure_erase() {
    local var_name="$1"
    
    if [ -n "$var_name" ]; then
        # Overwrite with random data
        eval "$var_name=\$(openssl rand -base64 32)"
        # Unset variable
        unset "$var_name"
    fi
}

# Rotate encryption keys
# Generates new key and re-encrypts all data
#
# Returns:
#   0 - Success
#   1 - Failure
rotate_encryption_key() {
    warning "Key rotation is a sensitive operation"
    warning "Ensure you have backups before proceeding"
    
    check_openssl || return 1
    
    # Get current key
    local old_key
    if [ -f "$ENCRYPTION_KEY_FILE" ]; then
        old_key=$(cat "$ENCRYPTION_KEY_FILE")
    else
        error "No encryption key found to rotate"
        return 1
    fi
    
    # Generate new key
    local new_key
    new_key=$(openssl rand -hex "$KEY_LENGTH")
    
    # Backup old key
    cp "$ENCRYPTION_KEY_FILE" "${ENCRYPTION_KEY_FILE}.backup"
    
    # Save new key
    echo "$new_key" > "$ENCRYPTION_KEY_FILE"
    chmod 600 "$ENCRYPTION_KEY_FILE"
    
    debug "New encryption key generated"
    debug "Old key backed up to ${ENCRYPTION_KEY_FILE}.backup"
    
    # Note: Re-encryption of existing files would need to be done separately
    warning "Existing encrypted files need to be re-encrypted with new key"
    
    return 0
}

# Generate secure random password
#
# Arguments:
#   $1 - optional length (default: 32)
#
# Returns:
#   Random password to stdout
generate_secure_password() {
    local length="${1:-32}"
    
    check_openssl || return 1
    
    openssl rand -base64 "$length" | tr -d '\n'
}

# Hash data using SHA-256
# Useful for password verification without storing plaintext
#
# Arguments:
#   $1 - data to hash
#
# Returns:
#   SHA-256 hash (hex) to stdout
hash_sha256() {
    local data="$1"
    
    check_openssl || return 1
    
    echo -n "$data" | openssl dgst -sha256 -hex | cut -d' ' -f2
}

# Verify if encrypted data is valid
# Attempts decryption without returning plaintext
#
# Arguments:
#   $1 - encrypted data
#   $2 - optional password
#
# Returns:
#   0 - Valid encrypted data
#   1 - Invalid or corrupted
verify_encrypted_data() {
    local encrypted="$1"
    local password="${2:-}"
    
    # Try to decrypt (redirect output to /dev/null)
    decrypt_data "$encrypted" "$password" > /dev/null 2>&1
    return $?
}

# Clean up encryption artifacts
# Removes keys and salts - USE WITH CAUTION
clean_encryption_data() {
    warning "This will remove all encryption keys and salts"
    warning "Encrypted data will become unrecoverable"
    
    if [ -f "$ENCRYPTION_KEY_FILE" ]; then
        # Create backup before removal
        cp "$ENCRYPTION_KEY_FILE" "${ENCRYPTION_KEY_FILE}.deleted.$(date +%s)"
        rm -f "$ENCRYPTION_KEY_FILE"
        debug "Removed encryption key"
    fi
    
    if [ -f "$SALT_FILE" ]; then
        cp "$SALT_FILE" "${SALT_FILE}.deleted.$(date +%s)"
        rm -f "$SALT_FILE"
        debug "Removed salt"
    fi
    
    return 0
}
