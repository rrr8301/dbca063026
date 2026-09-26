#!/bin/bash
set -e

# Run cargo tests in debug mode
echo "Running cargo test (debug mode)..."
cargo test --workspace --all-features

# Run cargo tests in release mode
echo "Running cargo test (release mode)..."
cargo test --workspace --all-features --release

echo "All tests completed successfully!"