#!/bin/bash

set -e

# Print Rust version for debugging
echo "Rust version:"
rustc --version
cargo --version

# Navigate to workspace root
cd /workspace

# Run cargo test with all features
# Use --no-fail-fast to ensure all tests run even if some fail
echo "Running cargo test with all features..."
cargo test --all-features --no-fail-fast

echo "All tests completed!"