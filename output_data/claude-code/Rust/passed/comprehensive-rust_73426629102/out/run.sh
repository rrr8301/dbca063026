#!/usr/bin/env bash
set -e

echo "=== Updating Rust ==="
rustup update

echo "=== Building Rust code ==="
cargo build

echo "=== Testing Rust code ==="
cargo test

echo "FINAL_STATUS = SUCCESS"
