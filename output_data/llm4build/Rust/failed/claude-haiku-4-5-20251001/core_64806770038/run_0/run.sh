#!/bin/bash
set -e

# Set Rust toolchain version
export RUSTUP_TOOLCHAIN=$RUST_VERSION

# Install the specified Rust toolchain
rustup toolchain install --profile minimal $RUSTUP_TOOLCHAIN

# Override the toolchain for this directory
rustup override set $RUSTUP_TOOLCHAIN

# Install cargo-nextest
cargo install cargo-nextest --locked

# Run tests with nextest
export RUST_BACKTRACE=1
cargo nextest run --workspace --locked