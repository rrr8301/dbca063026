#!/bin/bash
set -e

# Ensure Rust toolchain is available
export PATH="/root/.cargo/bin:${PATH}"
export CARGO_HOME="/root/.cargo"
export RUSTUP_HOME="/root/.rustup"

# Navigate to workspace
cd /workspace

# Build the project
echo "Building project..."
cargo build -v

# Run tests and generate documentation
echo "Running tests and generating documentation..."
cargo test -v
cargo doc -v

echo "All tests completed successfully!"