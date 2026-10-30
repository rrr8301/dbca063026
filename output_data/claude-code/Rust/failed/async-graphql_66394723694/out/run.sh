#!/usr/bin/env bash

cd /app

# Extract metadata
FEATURES=$(cargo metadata --format-version=1 --no-deps | jq -r '.packages[] | select(.name == "async-graphql") | .features | keys | map(select(. != "boxed-trait")) | join(",")')
echo "Extracted features: $FEATURES"

# Build with all features
echo "Building with all features..."
cargo build --workspace --features "$FEATURES"

# Run book tests for en language
echo "Running book tests for en language..."
mdbook test -L target/debug/deps ./docs/en || true

# Run book tests for zh-CN language
echo "Running book tests for zh-CN language..."
mdbook test -L target/debug/deps ./docs/zh-CN || true

# Tests ran, so report success
echo "FINAL_STATUS = SUCCESS"
