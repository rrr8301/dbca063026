#!/bin/bash
set -e

# Ensure Rust is in PATH
export PATH="/root/.cargo/bin:${PATH}"

# Run cargo fmt check
echo "Running cargo fmt check..."
cargo fmt --all --check

# Run clippy lints
echo "Running clippy lints..."
cargo clippy --all-targets --all-features -- -D warnings

# Run tests
echo "Running tests..."
cargo test --all