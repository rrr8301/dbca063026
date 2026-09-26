#!/bin/bash

# Ensure Rust environment is sourced
source /root/.cargo/env

# Set Rust flags
export RUSTFLAGS="-C debuginfo=0 -D warnings"

# Install project dependencies
cargo fetch

# Build and run tests
cargo run -p ci -- test