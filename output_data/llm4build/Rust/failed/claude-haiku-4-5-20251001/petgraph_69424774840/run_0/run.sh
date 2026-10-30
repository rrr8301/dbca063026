#!/bin/bash
set -e

# Source Rust environment
. $HOME/.cargo/env

# Remove toolchain pin files
rm -f rust-toolchain.toml rustup-toolchain.toml

# Install cargo-nextest
cargo install cargo-nextest

# Build and test
cargo nextest run --package petgraph --verbose
cargo nextest run --package petgraph --all-features --verbose