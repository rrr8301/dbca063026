#!/usr/bin/env bash

set -e

cd /app

echo "=== Building ==="
cargo build -v

echo "=== Testing ==="
cargo test -v && cargo doc -v

echo "FINAL_STATUS = SUCCESS"
