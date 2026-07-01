#!/bin/bash
set -e

# Source Rust environment
. $HOME/.cargo/env

# Display Rust version for debugging
echo "Rust version:"
rustc --version
cargo --version

# Run cargo test with all features
# Note: $DOCTEST_XCOMPILE is undefined in the workflow, so it expands to empty string
cargo test --workspace --all-features

echo "All tests completed successfully!"