#!/bin/bash

# Source the Rust environment
source /home/testuser/.cargo/env

# Remove rust-toolchain.toml
rm -f /workspace/rust-toolchain.toml

# Build the project
cargo build --verbose

# Build examples
cargo build --examples --verbose

# Run tests
cargo test --verbose