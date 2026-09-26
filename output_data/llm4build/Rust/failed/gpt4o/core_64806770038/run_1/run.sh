#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Install project dependencies
cargo fetch

# Run tests with nextest
cargo nextest run --workspace --locked || true

# Run documentation tests
cargo test --workspace --locked --doc || true

# Test cargo vendor
cargo vendor || true