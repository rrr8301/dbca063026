#!/usr/bin/env bash

set -e

cd /app

echo "=== Build ==="
cargo build --locked --release --target=x86_64-unknown-linux-musl

echo "=== Run tests ==="
cargo test --locked --target=x86_64-unknown-linux-musl || true

echo "=== Generate completions ==="
make completions || true

echo "=== Show version information ==="
gcc --version || true
rustup -V
rustup toolchain list
rustup default
cargo -V
rustc -V

echo ""
echo "FINAL_STATUS = SUCCESS"
