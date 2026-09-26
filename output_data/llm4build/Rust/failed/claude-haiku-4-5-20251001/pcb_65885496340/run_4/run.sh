#!/bin/bash
set -e

# Set environment variables for test execution
export RUST_LOG=debug
export RUST_BACKTRACE=full
export CARGO_TERM_COLOR=always
export CARGO_INCREMENTAL=0
export CARGO_PROFILE_TEST_DEBUG=0

# Ensure Rust is available (if running outside GitHub Actions)
if [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
fi

# Run tests with nextest
cargo nextest run --workspace --profile ci --locked