#!/bin/bash
set -e

# Source Rust environment
. $HOME/.cargo/env

# Set environment variables
export RUST_BACKTRACE=1
export CARGO_TARGET_DIR=/workspace/target
export NO_FMT_TEST=1
export CARGO_INCREMENTAL=0
export RUSTFLAGS="-D warnings"

# Ensure we're in the workspace
cd /workspace

# Verify Rust toolchain is installed
echo "Checking Rust toolchain..."
rustup show active-toolchain

# Build with tests
echo "Building with tests..."
cargo build --tests --features internal

# Run tests
echo "Running tests..."
cargo test --features internal

echo "All tests completed successfully!"