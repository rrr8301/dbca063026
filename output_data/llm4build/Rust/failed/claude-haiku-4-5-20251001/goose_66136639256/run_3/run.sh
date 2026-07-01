#!/bin/bash
set -e

# Activate Rust environment
export PATH="/home/testuser/.cargo/bin:${PATH}"

# Ensure rustup is available
rustup show

# Set environment variables for the test
export RUST_MIN_STACK=8388608
export CARGO_INCREMENTAL=0

# Navigate to crates directory and run tests
cd /workspace/crates

# Run all tests
echo "Running all tests..."
cargo test

echo "All tests completed successfully!"