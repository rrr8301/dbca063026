#!/bin/bash
set -e

# Install Rust nightly
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain nightly
source "$HOME/.cargo/env"

# Verify Rust installation
rustc --version
cargo --version

# Build
cargo build -v

# Test and generate documentation
cargo test -v && cargo doc -v