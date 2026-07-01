#!/bin/bash
set -e

# Ensure HOME is set
export HOME=${HOME:-/root}

# Add Rust to PATH if not already present
export PATH="$HOME/.cargo/bin:$PATH"

# Set environment variables
export CARGO_TERM_COLOR=always
export CARGO_INCREMENTAL=0
export CARGO_PROFILE_TEST_DEBUG=0
export CARGO_PROFILE_DEV_DEBUG=0
export NIGHTLY_TOOLCHAIN=nightly
export RUSTFLAGS="-C debuginfo=0 -D warnings"

# Verify Rust is available
if ! command -v cargo &> /dev/null; then
    echo "Error: Rust toolchain not found in PATH"
    exit 1
fi

# Build and run tests
cargo run -p ci -- test