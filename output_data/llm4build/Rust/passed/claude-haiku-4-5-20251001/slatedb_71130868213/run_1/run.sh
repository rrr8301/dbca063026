#!/bin/bash
set -e

# Set RUSTFLAGS as per job configuration
export RUSTFLAGS="-Dwarnings"

# Install nextest using install-action
echo "Installing nextest@0.9.98..."
install-action nextest@0.9.98

# Run Tests
echo "Running cargo nextest tests..."
cargo nextest run --workspace --all-features --profile ci

# Run Doc Tests
echo "Running doc tests..."
cargo test --doc --all-features

# Run DST Tests with special RUSTFLAGS
echo "Running DST tests..."
export RUSTFLAGS="--cfg dst --cfg tokio_unstable"
cargo nextest run -p slatedb-dst --all-features --profile dst

echo "All tests completed successfully!"