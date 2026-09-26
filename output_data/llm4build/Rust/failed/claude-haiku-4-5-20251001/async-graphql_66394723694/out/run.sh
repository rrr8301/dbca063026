#!/bin/bash
set -e

# Set Rust environment variables
export RUSTUP_HOME="/home/testuser/.rustup"
export CARGO_HOME="/home/testuser/.cargo"
export PATH="/home/testuser/.cargo/bin:${PATH}"

# Ensure default toolchain is set
rustup default stable

# Extract features from Cargo metadata
FEATURES=$(cargo metadata --format-version=1 --no-deps | jq -r '.packages[] | select(.name == "async-graphql") | .features | keys | map(select(. != "boxed-trait")) | join(",")')

echo "Extracted features: $FEATURES"

# Build with all features
echo "Building workspace with all features..."
cargo build --workspace --features "$FEATURES"

# Run book tests for en language
echo "Running mdBook tests for English documentation..."
mdbook test -L target/debug/deps ./docs/en

echo "All tests completed successfully!"