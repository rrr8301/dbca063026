#!/bin/bash

set -e

# Source Rust environment
source $HOME/.cargo/env

# Set environment variables
export NUSHELL_CARGO_PROFILE=ci
export NU_LOG_LEVEL=DEBUG
export CLIPPY_OPTIONS="-D warnings -D clippy::unwrap_used -D clippy::unchecked_time_subtraction"

# Clone the repository (assuming it's passed as an argument or environment variable)
# For local testing, the repo should be mounted or copied
if [ ! -d "/workspace/.git" ]; then
    echo "Repository not found. Assuming code is already in /workspace"
fi

cd /workspace

# Verify Rust installation
echo "Rust version:"
rustc --version
cargo --version

# Run tests
echo "Running cargo tests..."
cargo test --workspace --profile ci --exclude nu_plugin_* || TEST_FAILED=1

# Check for clean repo
echo "Checking for clean repository..."
if [ -n "$(git status --porcelain)" ]; then
    echo "ERROR: there are uncommitted changes:"
    git status --porcelain
    REPO_CLEAN_FAILED=1
else
    echo "OK: no changes in working directory"
fi

# Exit with failure if any step failed
if [ "$TEST_FAILED" = "1" ] || [ "$REPO_CLEAN_FAILED" = "1" ]; then
    exit 1
fi

echo "All checks passed!"
exit 0