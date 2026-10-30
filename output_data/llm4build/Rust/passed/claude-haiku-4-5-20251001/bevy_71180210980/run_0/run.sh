#!/bin/bash
set -e

# Set environment variables
export CARGO_TERM_COLOR=always
export CARGO_INCREMENTAL=0
export CARGO_PROFILE_TEST_DEBUG=0
export CARGO_PROFILE_DEV_DEBUG=0
export NIGHTLY_TOOLCHAIN=nightly
export RUSTFLAGS="-C debuginfo=0 -D warnings"

# Ensure Rust toolchain is available
rustup default stable
rustup update stable

# Build and run tests
cargo run -p ci -- test