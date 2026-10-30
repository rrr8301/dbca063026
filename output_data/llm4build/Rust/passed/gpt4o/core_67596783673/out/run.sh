#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Set environment variables
export RUSTFLAGS="-Dwarnings"
export RUST_BACKTRACE=1

# Run tests
cargo nextest run --workspace --locked

# Run documentation tests
cargo test --workspace --locked --doc

# Test cargo vendor
cargo vendor