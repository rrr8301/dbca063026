#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Install project dependencies (if any)
# Assuming dependencies are managed via Cargo.toml

# Run tests
cargo nextest run --all --exclude e2e_test
cargo test --all --doc