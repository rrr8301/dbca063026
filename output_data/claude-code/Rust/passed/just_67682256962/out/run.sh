#!/usr/bin/env bash

set -e

export USER="${USER:-root}"

echo "=== Running cargo test --all ==="
cargo test --all

echo "=== Running install.sh ==="
bash www/install.sh --to /tmp --tag 1.25.0

echo "=== Verifying just version ==="
/tmp/just --version

echo ""
echo "FINAL_STATUS = SUCCESS"
