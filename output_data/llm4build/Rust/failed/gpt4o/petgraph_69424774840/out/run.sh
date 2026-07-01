#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Activate Rust environment
source $HOME/.cargo/env

# Remove toolchain pin
rm -f rust-toolchain.toml rustup-toolchain.toml

# Build and test
if ! cargo nextest run --package petgraph --verbose; then
    echo "Tests failed"
    exit 1
fi

if ! cargo nextest run --package petgraph --all-features --verbose; then
    echo "Tests with all features failed"
    exit 1
fi