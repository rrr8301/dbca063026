#!/bin/bash
set -e

# Activate Rust environment
export PATH="/root/.cargo/bin:${PATH}"

# Verify Rust installation
rustc --version
cargo --version

# Install project dependencies (if needed via Cargo.lock)
cd /workspace

# Run tests with all features
echo "Running cargo tests with all features..."
cargo test --all-features

# Run doc-tests
echo "Running doc-tests with all features..."
cargo test --all-features --doc

echo "All tests completed successfully!"