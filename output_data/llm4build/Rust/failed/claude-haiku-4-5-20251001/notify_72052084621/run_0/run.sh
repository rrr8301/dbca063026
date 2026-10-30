#!/bin/bash
set -e

# Source cargo environment
. $HOME/.cargo/env

# Remove rust-toolchain.toml
rm -f rust-toolchain.toml

# Set Rust override to 1.88
rustup override set 1.88
rustup update 1.88

# Build
cargo build --verbose

# Build examples
cargo build --examples --verbose

# Run tests
cargo test --verbose