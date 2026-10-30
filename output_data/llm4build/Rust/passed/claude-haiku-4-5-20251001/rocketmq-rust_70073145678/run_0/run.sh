#!/bin/bash

set -e

# Source bashrc to get LIBCLANG_PATH
source /root/.bashrc

# Verify Rust installation
rustc --version
cargo --version

# Build with all features
echo "Building workspace with all features..."
cargo build --workspace --all-features

# Test with all features
echo "Running tests with all features..."
cargo test --workspace --all-features

echo "Build and test completed successfully!"