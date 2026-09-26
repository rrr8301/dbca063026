#!/bin/bash

# Remove rust-toolchain.toml if it exists
rm -f rust-toolchain.toml

# Build the project
cargo build --verbose

# Build examples
cargo build --examples --verbose

# Run tests
cargo test --verbose