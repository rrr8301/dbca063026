#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Remove toolchain pin
rm -f rust-toolchain.toml rustup-toolchain.toml

# Build and test
cargo nextest run --package petgraph --verbose
cargo nextest run --package petgraph --all-features --verbose