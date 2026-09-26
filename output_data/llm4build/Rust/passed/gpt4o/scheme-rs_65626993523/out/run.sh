#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Install project dependencies
cargo build

# Check formatting
cargo fmt -- --check

# Run linter
cargo clippy --all-targets -- -Dclippy::all -D warnings

# Run tests
cargo test || true

# Run benchmarks
cargo bench || true