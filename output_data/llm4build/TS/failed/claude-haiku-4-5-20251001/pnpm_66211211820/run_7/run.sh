#!/bin/bash

set -e

# Configure Git
git config --global core.autocrlf false
git config --global user.name "xyz"
git config --global user.email "x@y.z"

# Set shell environment
export SHELL=/bin/bash

# Verify pnpm is available
if ! command -v pnpm &> /dev/null; then
    echo "Error: pnpm not found in PATH"
    echo "PATH: $PATH"
    exit 1
fi

# Verify Node.js is available
echo "Verifying Node.js..."
node --version
npm --version
pnpm --version

# Install project dependencies
echo "Installing pnpm dependencies..."
pnpm install

# Handle compiled artifacts (if present)
if [ -f "compiled.tar.gz" ]; then
    echo "Extracting compiled artifacts..."
    tar -xzf compiled.tar.gz
else
    echo "Note: compiled.tar.gz not found. Using locally built artifacts."
fi

# Determine test scope
# Default to ci:test-all for local execution (safest option)
TEST_SCRIPT="ci:test-all"
TEST_SCOPE="all"

# If git history is available, check for workspace changes
if git rev-parse --verify origin/main >/dev/null 2>&1; then
    if [ -n "$(git diff --name-only origin/main HEAD -- pnpm-workspace.yaml 2>/dev/null || echo '')" ]; then
        TEST_SCRIPT="ci:test-all"
        TEST_SCOPE="all — pnpm-workspace.yaml modified"
    else
        TEST_SCRIPT="ci:test-branch"
        TEST_SCOPE="affected packages"
    fi
fi

echo "Test scope: $TEST_SCOPE"
echo "Running: pnpm run $TEST_SCRIPT"

# Run tests with pnpm
export PNPM_WORKERS=3
pnpm run "$TEST_SCRIPT"

echo "Tests completed successfully!"