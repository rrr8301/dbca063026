#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Install project dependencies (if any)
# Assuming no additional dependencies are needed beyond Cargo.toml

# Run tests
set -e
cargo test || true  # Ensure all tests run even if some fail