#!/bin/bash
set -e

# Set environment variables
export RUSTFLAGS="-D warnings"
export RUSTDOCFLAGS="-D warnings"
export NIGHTLY_VERSION="nightly-2025-09-16"

# Verify Rust installation
rustc --version
cargo --version

# Run tests with all features
echo "Running cargo tests with all features..."
cargo test --all-features

# Run doc-tests
echo "Running doc-tests..."
cargo test --all-features --doc

echo "All tests completed successfully!"