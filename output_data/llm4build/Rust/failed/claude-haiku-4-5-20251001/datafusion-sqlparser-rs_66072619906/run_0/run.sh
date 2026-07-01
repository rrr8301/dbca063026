#!/bin/bash
set -e

# Ensure Rust is available
export PATH="/root/.cargo/bin:${PATH}"

# Install cargo-tarpaulin for code coverage
cargo install cargo-tarpaulin

# Run tests with all features
cargo test --all-features