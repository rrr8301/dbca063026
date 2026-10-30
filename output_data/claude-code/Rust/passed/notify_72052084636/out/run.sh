#!/usr/bin/env bash
set -e

echo "=== Building ==="
cargo build --verbose

echo "=== Building examples ==="
cargo build --examples --verbose

echo "=== Running tests ==="
cargo test --workspace --exclude examples --verbose

echo "FINAL_STATUS = SUCCESS"
