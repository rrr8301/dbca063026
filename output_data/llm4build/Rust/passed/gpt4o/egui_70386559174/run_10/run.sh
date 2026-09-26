#!/bin/bash

# Clone the repository
git clone --recurse-submodules <repository-url> /app
cd /app

# Set up Rust toolchain
rustup override set 1.92.0

# Run tests
cargo test --all-features

# Run doc-tests
cargo test --all-features --doc