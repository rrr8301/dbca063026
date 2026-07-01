#!/bin/bash
set -e

# Ensure Rust is available
. $HOME/.cargo/env

# Remove rust-toolchain.toml to allow nightly override
rm -f rust-toolchain.toml

# Install Rust nightly
rustup override set nightly
rustup update nightly

# Build
cargo build --verbose

# Build examples
cargo build --examples --verbose

# Run tests
cargo test --verbose