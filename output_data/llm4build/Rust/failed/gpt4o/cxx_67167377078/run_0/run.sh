#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Install project dependencies
cargo build --manifest-path demo/Cargo.toml

# Determine test suite subset
RUSTFLAGS="--cfg deny_warnings -Dwarnings"
EXCLUDE="--exclude cxx-test-suite"

# Run the project
cargo run --manifest-path demo/Cargo.toml

# Run tests
cargo test --workspace $EXCLUDE || true

# Run additional checks
cargo check --no-default-features --features alloc || true
cargo check --no-default-features || true