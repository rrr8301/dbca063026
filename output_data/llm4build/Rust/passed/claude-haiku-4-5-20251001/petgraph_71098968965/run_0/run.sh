#!/bin/bash
set -e

# Remove toolchain pin files
rm -f rust-toolchain.toml rustup-toolchain.toml

# Build and test petgraph
echo "Running cargo nextest for petgraph..."
cargo nextest run --package petgraph --verbose

echo "Running cargo nextest for petgraph with all features..."
cargo nextest run --package petgraph --all-features --verbose

echo "All tests completed successfully!"