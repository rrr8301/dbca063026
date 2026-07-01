#!/bin/bash

# Simple command to verify the script runs
echo "run.sh executed successfully"

# Run tests using cargo-nextest
cargo nextest run --all --exclude e2e_test

# Run documentation tests
cargo test --all --doc

# Check code formatting
cargo fmt --all --check

# Run clippy lints
cargo clippy --all-targets --all-features -- -D warnings

# Check layered dependencies
./scripts/check_layer_dependencies.sh