#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Remove rust-toolchain.toml
rm -f rust-toolchain.toml

# Build the project
cargo build --verbose

# Build examples
cargo build --examples --verbose

# Run tests
cargo test --verbose