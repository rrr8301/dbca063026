#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Navigate to the app directory
cd /app

# Install project dependencies (simulating setup-rbmt)
# Assuming setup-rbmt installs necessary Rust tools and dependencies
rustup toolchain install stable
rustup default stable

# Run tests
cargo test --locked