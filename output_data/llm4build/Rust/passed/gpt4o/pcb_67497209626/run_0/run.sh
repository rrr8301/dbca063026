#!/bin/bash

# Source Rust environment
source "$HOME/.cargo/env"

# Set environment variables
export CARGO_TERM_COLOR=always
export CARGO_INCREMENTAL=0
export CARGO_PROFILE_TEST_DEBUG=0
export RUST_LOG=debug
export RUST_BACKTRACE=full

# Install project dependencies
cargo build --release

# Run tests
cargo nextest run --workspace --profile ci --locked

# Run doctests
cargo test --doc --workspace --locked