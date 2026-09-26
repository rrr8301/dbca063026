#!/bin/bash
set -e

# Set environment variables
export CARGO_TERM_COLOR=always

# Update Rust toolchain to latest stable
rustup update

# Build Rust code
cargo build

# Test Rust code
cargo test