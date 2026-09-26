#!/usr/bin/env bash

set -e

echo "=== Running cargo test --all ==="
cargo test --all

echo ""
echo "=== Testing install.sh ==="
bash /app/www/install.sh --to /tmp --tag 1.25.0
/tmp/just --version

echo ""
echo "FINAL_STATUS = SUCCESS"
