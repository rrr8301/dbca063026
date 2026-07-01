#!/bin/bash
set -e

# Activate Rust environment
export PATH="/home/testuser/.cargo/bin:${PATH}"

# Build tests
echo "Building tests..."
cargo test --no-run --all --exclude niri-visual-tests

# Run tests
echo "Running tests..."
cargo test --all --exclude niri-visual-tests -- --nocapture