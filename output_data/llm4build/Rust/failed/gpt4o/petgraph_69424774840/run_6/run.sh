#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Activate Rust environment
source $HOME/.cargo/env

# Remove toolchain pin
rm -f rust-toolchain.toml rustup-toolchain.toml

# Build and test
cargo nextest run --package petgraph --verbose || { echo "Tests failed"; exit 1; }
cargo nextest run --package petgraph --all-features --verbose || { echo "Tests with all features failed"; exit 1; }