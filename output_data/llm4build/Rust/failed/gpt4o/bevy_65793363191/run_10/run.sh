#!/bin/bash

# Ensure Rust environment is sourced
source /root/.cargo/env

# Set Rust flags, allowing the specific warning for ambiguous import visibility
export RUSTFLAGS="-C debuginfo=0 -D warnings -A ambiguous_import_visibilities"

# Install project dependencies
cargo fetch

# Build and run tests
cargo test