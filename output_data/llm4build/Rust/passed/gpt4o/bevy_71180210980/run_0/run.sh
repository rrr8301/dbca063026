#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Install project dependencies
# (Assuming dependencies are specified in Cargo.toml and will be handled by cargo)

# Run tests
cargo run -p ci -- test