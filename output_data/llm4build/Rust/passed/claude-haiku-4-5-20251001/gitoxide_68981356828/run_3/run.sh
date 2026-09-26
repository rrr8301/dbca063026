#!/bin/bash
set -e

# Activate Rust environment
export PATH="/root/.cargo/bin:${PATH}"

# Update Rust to stable
rustup update stable
rustup default stable

# Install project dependencies (Cargo will handle this)
echo "Building project..."
cargo build --all

# Run tests with nextest
echo "Running tests..."
export GIX_TEST_IGNORE_ARCHIVES=1

# Run the test command via just
just ci-test

echo "All tests completed successfully!"