#!/bin/bash

set -e

# Source Rust environment
. $HOME/.cargo/env

# Install project dependencies
echo "Installing project dependencies..."
pnpm install --frozen-lockfile

# Run linting
echo "Running linter..."
pnpm lint || LINT_FAILED=1

# Run tests
echo "Running tests..."
pnpm test || TEST_FAILED=1

# Exit with failure if any step failed
if [ "$LINT_FAILED" = "1" ] || [ "$TEST_FAILED" = "1" ]; then
    exit 1
fi

exit 0