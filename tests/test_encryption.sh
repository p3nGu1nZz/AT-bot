#!/bin/bash
# Comprehensive encryption tests for atproto
# Tests both lib/crypt.sh module and integration with lib/atproto.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LIB_DIR="$PROJECT_ROOT/lib"

# Test directory
TEST_CRYPT_DIR="/tmp/atproto-crypt-test-$$"
export CRYPT_DIR="$TEST_CRYPT_DIR"
export XDG_CONFIG_HOME="$(dirname "$TEST_CRYPT_DIR")"

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Setup test environment
setup_test() {
    mkdir -p "$TEST_CRYPT_DIR"
    export ENCRYPTION_KEY_FILE="$TEST_CRYPT_DIR/encryption.key"
    export SALT_FILE="$TEST_CRYPT_DIR/encryption.salt"
}

# Cleanup test environment
cleanup_test() {
    rm -rf "$TEST_CRYPT_DIR"
}

# Pass/fail helper
pass_test() {
    echo "[PASS] $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

fail_test() {
    echo "[FAIL] $1"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

# Source the library (which sources lib/crypt.sh)
# shellcheck source=../lib/atproto.sh
source "$PROJECT_ROOT/lib/atproto.sh"

echo "================================"
echo "atproto Encryption Test Suite"
echo "================================"
echo ""

setup_test

# Test 1: OpenSSL availability
echo "Test 1: OpenSSL availability..."
if check_openssl; then
    pass_test "OpenSSL is available"
else
    fail_test "OpenSSL not found"
fi

# Test 2: Key generation
echo "Test 2: Key generation and persistence..."
key=$(generate_or_get_key)
if [ -z "$key" ]; then
    fail_test "Key generation returned empty"
elif [ ! -f "$ENCRYPTION_KEY_FILE" ]; then
    fail_test "Key file not created"
elif [ ${#key} -ne 64 ]; then
    fail_test "Key length incorrect (expected 64, got ${#key})"
else
    key2=$(generate_or_get_key)
    if [ "$key" != "$key2" ]; then
        fail_test "Key not persistent"
    else
        pass_test "Key generation and persistence"
    fi
fi

# Test 3: Salt generation
echo "Test 3: Salt generation and persistence..."
salt=$(generate_or_get_salt)
if [ -z "$salt" ]; then
    fail_test "Salt generation returned empty"
elif [ ! -f "$SALT_FILE" ]; then
    fail_test "Salt file not created"
elif [ ${#salt} -ne 64 ]; then
    fail_test "Salt length incorrect (expected 64, got ${#salt})"
else
    pass_test "Salt generation and persistence"
fi

# Test 4: Basic encryption/decryption
echo "Test 4: Basic encryption/decryption..."
plaintext="Hello, World! This is a test message. 🔐"
encrypted=$(encrypt_data "$plaintext")
if [ -z "$encrypted" ]; then
    fail_test "Encryption returned empty"
elif [ "$encrypted" = "$plaintext" ]; then
    fail_test "Encrypted data same as plaintext"
else
    decrypted=$(decrypt_data "$encrypted")
    if [ "$decrypted" != "$plaintext" ]; then
        fail_test "Decrypted data doesn't match original"
    else
        pass_test "Basic encryption/decryption"
    fi
fi

# Test 5: Password-based encryption
echo "Test 5: Password-based encryption..."
plaintext="Secret data with custom password"
password="MySecurePassword123!"
encrypted=$(encrypt_data "$plaintext" "$password")
if [ -z "$encrypted" ]; then
    fail_test "Password encryption returned empty"
else
    decrypted=$(decrypt_data "$encrypted" "$password")
    if [ "$decrypted" != "$plaintext" ]; then
        fail_test "Password decryption failed"
    else
        wrong_decrypt=$(decrypt_data "$encrypted" "WrongPassword" 2>/dev/null || echo "")
        if [ "$wrong_decrypt" = "$plaintext" ]; then
            fail_test "Wrong password decryption succeeded (security issue!)"
        else
            pass_test "Password-based encryption"
        fi
    fi
fi

# Test 6: PBKDF2 key derivation
echo "Test 6: PBKDF2 key derivation..."
passphrase="MyPassphrase123"
derived_key=$(derive_key_from_passphrase "$passphrase")
if [ -z "$derived_key" ]; then
    fail_test "Key derivation returned empty"
else
    derived_key2=$(derive_key_from_passphrase "$passphrase")
    if [ "$derived_key" != "$derived_key2" ]; then
        fail_test "Key derivation not deterministic"
    else
        derived_key3=$(derive_key_from_passphrase "DifferentPassphrase")
        if [ "$derived_key" = "$derived_key3" ]; then
            fail_test "Different passphrases produced same key"
        else
            pass_test "PBKDF2 key derivation"
        fi
    fi
fi

# Test 7: File encryption/decryption
echo "Test 7: File encryption/decryption..."
test_file="$TEST_CRYPT_DIR/test_file.txt"
original_content="This is a test file with secure data"
printf '%s' "$original_content" > "$test_file"
if ! encrypt_file "$test_file"; then
    fail_test "File encryption failed"
elif [ ! -f "${test_file}.backup" ]; then
    fail_test "Backup not created"
else
    encrypted_content=$(cat "$test_file")
    if [ "$encrypted_content" = "$original_content" ]; then
        fail_test "File not encrypted"
    else
        if ! decrypt_file "$test_file"; then
            fail_test "File decryption failed"
        else
            decrypted_content=$(cat "$test_file")
            if [ "$decrypted_content" != "$original_content" ]; then
                fail_test "Decrypted file content doesn't match"
            else
                pass_test "File encryption/decryption"
            fi
        fi
    fi
fi

# Test 8: SHA-256 hashing
echo "Test 8: SHA-256 hashing..."
data="test data for hashing"
hash=$(hash_sha256 "$data")
if [ -z "$hash" ]; then
    fail_test "Hashing returned empty"
elif [ ${#hash} -ne 64 ]; then
    fail_test "Hash length incorrect (expected 64, got ${#hash})"
else
    hash2=$(hash_sha256 "$data")
    if [ "$hash" != "$hash2" ]; then
        fail_test "Hashing not deterministic"
    else
        hash3=$(hash_sha256 "different data")
        if [ "$hash" = "$hash3" ]; then
            fail_test "Different data produced same hash"
        else
            pass_test "SHA-256 hashing"
        fi
    fi
fi

# Test 9: Secure password generation
echo "Test 9: Secure password generation..."
password=$(generate_secure_password)
if [ -z "$password" ]; then
    fail_test "Password generation returned empty"
else
    password2=$(generate_secure_password)
    if [ "$password" = "$password2" ]; then
        fail_test "Generated passwords are identical"
    else
        pass_test "Secure password generation"
    fi
fi

# Test 10: Encrypted data verification
echo "Test 10: Encrypted data verification..."
plaintext="Test data"
password="TestPassword"
encrypted=$(encrypt_data "$plaintext" "$password")
if ! verify_encrypted_data "$encrypted" "$password"; then
    fail_test "Valid encrypted data not verified"
elif verify_encrypted_data "$encrypted" "WrongPassword" 2>/dev/null; then
    fail_test "Invalid password verified as correct"
else
    pass_test "Encrypted data verification"
fi

# Test 11: Integration with atproto.sh
echo "Test 11: Integration with atproto.sh..."
if ! type encrypt_data >/dev/null 2>&1; then
    fail_test "encrypt_data not available in atproto.sh"
elif ! type decrypt_data >/dev/null 2>&1; then
    fail_test "decrypt_data not available in atproto.sh"
elif ! type generate_or_get_key >/dev/null 2>&1; then
    fail_test "generate_or_get_key not available in atproto.sh"
elif ! type hash_sha256 >/dev/null 2>&1; then
    fail_test "hash_sha256 not available in atproto.sh"
elif ! type secure_erase >/dev/null 2>&1; then
    fail_test "secure_erase not available in atproto.sh"
else
    pass_test "Integration with atproto.sh"
fi

cleanup_test

echo ""
echo "================================"
echo "Tests passed: $TESTS_PASSED"
echo "Tests failed: $TESTS_FAILED"
echo "================================"

if [ $TESTS_FAILED -eq 0 ]; then
    echo "All encryption tests passed!"
    exit 0
else
    echo "Some encryption tests failed!"
    exit 1
fi

