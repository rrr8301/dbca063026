#!/bin/bash
set -e

# Ensure Rust is available
export PATH="/root/.cargo/bin:${PATH}"

# Verify Rust installation
rustc --version
cargo --version

# Run tests
cargo test --workspace --all-features