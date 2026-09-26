#!/bin/bash
set -e

# Set environment variables for test execution
export RUST_BACKTRACE=1
export CARGO_TERM_COLOR=always

# Navigate to workspace
cd /workspace

# Run cargo test for the entire workspace
echo "Running cargo test --workspace..."
cargo test --workspace

echo "All tests completed successfully!"