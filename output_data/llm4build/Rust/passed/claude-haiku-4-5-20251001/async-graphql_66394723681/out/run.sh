#!/bin/bash
set -e

# Source Rust environment
. $HOME/.cargo/env

# Navigate to workspace
cd /workspace

# Initialize submodules (in case they weren't copied)
git submodule update --init --recursive 2>/dev/null || true

# Extract metadata for features
echo "Extracting metadata..."
FEATURES=$(cargo metadata --format-version=1 --no-deps | jq -r '.packages[] | select(.name == "async-graphql") | .features | keys | map(select(. != "boxed-trait")) | join(",")')
echo "Extracted features: $FEATURES"

# Build with all features
echo "Building with all features..."
cargo build --all-features

# Build with all features except boxed-trait
echo "Building with all features except boxed-trait..."
cargo build --features "$FEATURES"

# Build workspace
echo "Building workspace..."
cargo build --workspace --verbose

# Run tests
echo "Running tests..."
cargo test --workspace --features "$FEATURES"

# Clean
echo "Cleaning..."
cargo clean

echo "All tests completed successfully!"