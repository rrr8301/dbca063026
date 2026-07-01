#!/bin/bash

set -e

# Print commands for debugging
set -x

# Ensure Rust is available
export PATH="/root/.cargo/bin:${PATH}"

# Navigate to workspace
cd /workspace

# Install project dependencies (if needed)
cargo fetch

# Run lints
echo "Running lints..."
cargo fmt --all --check || LINT_FAILED=1

# Run tests
echo "Running tests..."
cargo nextest run --all-features --no-fail-fast --workspace || TEST_FAILED=1

# Report results
if [ "$LINT_FAILED" = "1" ] || [ "$TEST_FAILED" = "1" ]; then
    echo "Some checks failed"
    exit 1
fi

echo "All checks passed!"
exit 0