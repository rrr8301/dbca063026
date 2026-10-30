#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Install project dependencies (if any)
# Assuming no additional dependencies are specified in Cargo.toml

# Run tests
set -e
cargo test --all-features || true