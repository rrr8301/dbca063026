#!/bin/bash

set -e

# Set Cargo environment variables for CI builds
export CARGO_INCREMENTAL=0
export CARGO_PROFILE_DEV_DEBUG=0

# Ensure Rust toolchain is available
rustup default stable
rustup component add llvm-tools-preview

# Show versions for debugging
echo "=== Environment Info ==="
protoc --version
python3 --version
rustc -vV
cargo --version
echo "========================"

# Create coverage directories
mkdir -p coverage

# Run all tests
echo "Running cargo test --all..."
cargo test --all

echo "All tests completed successfully!"