#!/bin/bash

set -e

# Print Rust version for debugging
echo "Rust version:"
rustc --version
echo "Cargo version:"
cargo --version

# Navigate to the workspace
cd /workspace

# Run cargo tests
echo "Running cargo tests..."
cargo test

echo "All tests completed successfully!"