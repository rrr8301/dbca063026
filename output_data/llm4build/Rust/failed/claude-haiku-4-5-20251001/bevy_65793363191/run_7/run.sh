#!/bin/bash

set -e

# Source Rust environment to ensure cargo is available
source /root/.cargo/env

# Set environment variables
export CARGO_TERM_COLOR=always
export CARGO_INCREMENTAL=0
export CARGO_PROFILE_TEST_DEBUG=0
export CARGO_PROFILE_DEV_DEBUG=0
export RUSTFLAGS="-C debuginfo=0 -D warnings"

# Verify cargo is available
cargo --version

# Build and run tests
cargo run -p ci -- test