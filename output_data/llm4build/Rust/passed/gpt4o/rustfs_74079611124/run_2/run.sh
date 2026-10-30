#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Install project dependencies
cargo build --release

# Run tests
cargo nextest run --all --exclude e2e_test
cargo test --all --doc

# Check code formatting
cargo fmt --all --check

# Run clippy lints
cargo clippy --all-targets --all-features -- -D warnings

# Check layered dependencies
./scripts/check_layer_dependencies.sh