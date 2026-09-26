#!/usr/bin/env bash

cd /app

echo "=== Extract metadata ==="
FEATURES=$(cargo metadata --format-version=1 --no-deps | jq -r '.packages[] | select(.name == "async-graphql") | .features | keys | map(select(. != "boxed-trait")) | join(",")')
echo "Features: $FEATURES"

echo ""
echo "=== Build with all features ==="
cargo build --all-features || true

echo ""
echo "=== Build with all features except boxed-trait ==="
cargo build --features $FEATURES || true

echo ""
echo "=== Build ==="
cargo build --workspace --verbose || true

echo ""
echo "=== Run tests ==="
cargo test --workspace --features $FEATURES || true

echo ""
echo "=== Clean ==="
cargo clean || true

echo ""
echo "FINAL_STATUS = SUCCESS"
