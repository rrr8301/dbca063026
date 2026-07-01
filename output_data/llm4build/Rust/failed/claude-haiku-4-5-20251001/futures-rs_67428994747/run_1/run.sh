#!/bin/bash
set -e

# Source Rust environment
. $HOME/.cargo/env

# Display Rust version for debugging
echo "Rust version:"
rustc --version
cargo --version

# Run cargo test with all features
cargo test --workspace --all-features

echo "All tests completed successfully!"