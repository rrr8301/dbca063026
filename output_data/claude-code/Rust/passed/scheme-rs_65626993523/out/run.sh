#!/usr/bin/env bash
set -e

echo "=== Building ==="
cargo build

echo "=== Checking formatting ==="
cargo fmt -- --check

echo "=== Running Clippy ==="
cargo clippy --all-targets -- -Dclippy::all -D warnings

echo "=== Running tests ==="
cargo test

echo "=== Running benchmarks ==="
cargo bench

echo "FINAL_STATUS = SUCCESS"
