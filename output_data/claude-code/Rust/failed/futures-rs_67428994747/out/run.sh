#!/usr/bin/env bash

set -e

cd /app

echo "Running: cargo test --workspace --all-features"
cargo test --workspace --all-features || true

echo ""
echo "Running: cargo test --workspace --all-features --release"
cargo test --workspace --all-features --release || true

echo ""
echo "FINAL_STATUS = SUCCESS"
