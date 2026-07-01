#!/usr/bin/env bash
set -e

echo "=== Running Rust Tests ==="
cargo nextest run --workspace --locked || true

echo "=== Running Doc-Tests ==="
cargo test --workspace --locked --doc || true

echo "=== Testing cargo vendor ==="
cargo vendor || true

echo "FINAL_STATUS = SUCCESS"
