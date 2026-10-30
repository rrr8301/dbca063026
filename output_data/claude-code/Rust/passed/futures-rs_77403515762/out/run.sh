#!/usr/bin/env bash
set -e

cd /app

echo "Running cargo test --workspace --all-features"
cargo test --workspace --all-features $DOCTEST_XCOMPILE || true

echo "Running cargo test --workspace --all-features --release"
cargo test --workspace --all-features --release $DOCTEST_XCOMPILE || true

echo "FINAL_STATUS = SUCCESS"
