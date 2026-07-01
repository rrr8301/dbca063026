#!/bin/bash
set -e

# Ensure Rust environment is properly sourced
. $HOME/.cargo/env

# Remove toolchain pin files
rm -f rust-toolchain.toml rustup-toolchain.toml

# Install cargo-nextest with --locked flag
cargo install --locked cargo-nextest

# Build and test
cargo nextest run --package petgraph --verbose
cargo nextest run --package petgraph --all-features --verbose