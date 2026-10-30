#!/bin/bash
set -e

# Ensure Rust toolchain is available
export PATH="/root/.cargo/bin:${PATH}"

# Verify Rust installation
rustc --version
cargo --version

# Install Tarpaulin
cargo install cargo-tarpaulin

# Run tests with all features
cargo test --all-features