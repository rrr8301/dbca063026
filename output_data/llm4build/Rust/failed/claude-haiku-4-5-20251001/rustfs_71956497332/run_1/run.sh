#!/bin/bash

set -e

# Set Rust environment variables
export CARGO_TERM_COLOR=always
export RUST_BACKTRACE=1
export CARGO_BUILD_JOBS=2

# Run tests with cargo-nextest (excluding e2e_test)
echo "Running cargo nextest..."
cargo nextest run --all --exclude e2e_test

# Run doc tests
echo "Running cargo doc tests..."
cargo test --all --doc

# Check code formatting
echo "Checking code formatting..."
cargo fmt --all --check

# Run clippy lints
echo "Running clippy lints..."
cargo clippy --all-targets --all-features -- -D warnings

# Check layered dependencies
echo "Checking layered dependencies..."
./scripts/check_layer_dependencies.sh

echo "All checks passed!"