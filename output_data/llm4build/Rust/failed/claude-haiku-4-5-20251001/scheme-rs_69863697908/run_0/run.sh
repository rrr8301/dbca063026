#!/bin/bash

set -e

# Ensure Rust is available
export PATH="/root/.cargo/bin:${PATH}"

# Build
echo "Building..."
cargo build

# Check formatting
echo "Checking formatting..."
cargo fmt -- --check

# Clippy linting
echo "Running Clippy..."
cargo clippy --all-targets -- -Dclippy::all -D warnings

# Test
echo "Running tests..."
cargo test