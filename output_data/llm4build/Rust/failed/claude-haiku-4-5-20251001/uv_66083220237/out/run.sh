#!/bin/bash

set -e

# Navigate to workspace
cd /workspace

# Check if rust-toolchain.toml exists and use it
if [ -f "crates/uv-trampoline/rust-toolchain.toml" ]; then
    echo "Found rust-toolchain.toml, Rust toolchain will be managed by it"
fi

# Update Rust toolchain if rust-toolchain.toml is present
if [ -f "rust-toolchain.toml" ]; then
    rustup update
fi

# Run cargo test
echo "Running cargo test..."
cargo test

echo "All tests completed successfully!"