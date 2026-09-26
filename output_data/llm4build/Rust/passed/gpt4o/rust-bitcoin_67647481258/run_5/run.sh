#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Navigate to the app directory
cd /app

# Install project dependencies (simulating setup-rbmt)
# Assuming setup-rbmt installs necessary Rust tools and dependencies
rustup toolchain install stable
rustup default stable

# Check if Cargo.lock exists
if [ ! -f Cargo.lock ]; then
    # Generate the lock file if it doesn't exist
    cargo generate-lockfile
fi

# Run tests
cargo test