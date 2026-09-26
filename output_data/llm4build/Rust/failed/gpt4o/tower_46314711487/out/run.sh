#!/bin/bash

# Clone the repository (simulating actions/checkout)
git clone . /app

# Navigate to the project directory
cd /app

# Install Rust stable toolchain
rustup default stable

# Run tests
cargo test --workspace --all-features