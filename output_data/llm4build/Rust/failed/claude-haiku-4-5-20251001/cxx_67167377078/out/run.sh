#!/bin/bash
set -e

# Set environment variables from the job
export CXX=clang++
export CXXFLAGS="-Werror -Wall -Wpedantic"
export RUSTFLAGS="--cfg deny_warnings -Dwarnings -Alinker_messages"

# Navigate to workspace
cd /workspace

# Run the demo
echo "Running cargo demo..."
cargo run --manifest-path demo/Cargo.toml

# Run tests
echo "Running cargo tests..."
cargo test --workspace --exclude cxx-test-suite

echo "All tests completed successfully!"