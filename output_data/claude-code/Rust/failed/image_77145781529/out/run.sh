#!/usr/bin/env bash
set -e

cd /app

echo "Running tests..."
cargo test -v && cargo doc -v

echo "FINAL_STATUS = SUCCESS"
