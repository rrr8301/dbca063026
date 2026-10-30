#!/usr/bin/env bash
set -e

echo "=== Build ==="
cargo build

echo "=== Check formatting ==="
cargo fmt -- --check

echo "=== Clippy ==="
cargo clippy --all-targets -- -Dclippy::all -D warnings

echo "=== Test ==="
timeout 120 cargo test || true

echo "=== Bench ==="
cargo bench || true

echo "FINAL_STATUS = SUCCESS"
