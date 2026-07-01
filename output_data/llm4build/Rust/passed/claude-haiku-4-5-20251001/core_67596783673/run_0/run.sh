#!/bin/bash

set -e

# Set environment variables
export RUSTUP_TOOLCHAIN=1.94.0
export RUST_BACKTRACE=1
export RUSTFLAGS=-Dwarnings

# Override toolchain
rustup override set $RUSTUP_TOOLCHAIN

# Install nextest
cargo install cargo-nextest

# Run tests with nextest
echo "Running cargo nextest tests..."
cargo nextest run --workspace --locked

# Run doc tests
echo "Running doc tests..."
cargo test --workspace --locked --doc

# Test cargo vendor
echo "Testing cargo vendor..."
cargo vendor

echo "All tests passed!"