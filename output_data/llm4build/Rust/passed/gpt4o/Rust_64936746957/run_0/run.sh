#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Clone the repository (simulating actions/checkout)
git clone https://github.com/TheAlgorithms/Rust.git /app
cd /app

# Install project dependencies (if any)
# Rust projects typically manage dependencies via Cargo.toml, so no additional steps needed

# Run tests
cargo test -- --continue-on-error