#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Install project dependencies
cargo build --manifest-path demo/Cargo.toml

# Run tests
set +e  # Continue on error
cargo run --manifest-path demo/Cargo.toml
cargo test --workspace --exclude cxx-test-suite
cargo check --no-default-features --features alloc
cargo check --no-default-features

# Ensure all tests are executed
set -e