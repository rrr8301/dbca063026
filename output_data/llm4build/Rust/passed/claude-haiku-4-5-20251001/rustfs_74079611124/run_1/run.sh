#!/bin/bash

set -e

# Print commands for debugging
set -x

# Ensure we're in the workspace directory
cd /workspace

# Run tests with cargo-nextest (excluding e2e_test)
cargo nextest run --all --exclude e2e_test

# Run doc tests
cargo test --all --doc

# Check code formatting
cargo fmt --all --check

# Run clippy lints
cargo clippy --all-targets --all-features -- -D warnings

# Check layered dependencies
./scripts/check_layer_dependencies.sh

echo "All tests and lints passed!"