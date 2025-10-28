#!/bin/bash
# Unit test runner for AT-bot
# This script runs the unit tests from the tests directory
# It's designed to be used in CI/CD environments

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Change to project root
cd "$PROJECT_ROOT"

# Make sure test scripts are executable
chmod +x tests/*.sh

# Run the test suite
echo "Running AT-bot unit tests..."
bash tests/run_tests.sh

exit $?
