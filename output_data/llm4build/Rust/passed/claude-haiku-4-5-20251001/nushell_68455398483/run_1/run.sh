#!/bin/bash

set -e

# Source Rust environment
source /root/.cargo/env

# Update Rust to beta toolchain
echo "Updating Rust to beta toolchain..."
rustup update beta

# Run tests with beta toolchain
echo "Running tests with beta toolchain..."
cargo +beta test --workspace --profile ci --exclude nu_plugin_* || TEST_FAILED=1

# Check for clean repo
echo "Checking for clean repository..."
if [ -n "$(git status --porcelain)" ]; then
    echo "ERROR: there are uncommitted changes:"
    git status --porcelain
    REPO_CLEAN_FAILED=1
else
    echo "Repository is clean"
fi

# Exit with failure if any checks failed
if [ "${TEST_FAILED}" = "1" ] || [ "${REPO_CLEAN_FAILED}" = "1" ]; then
    exit 1
fi

echo "All checks passed!"
exit 0