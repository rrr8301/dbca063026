#!/usr/bin/env bash
set -e

cd /app

echo "Running cargo test --all-features..."
cargo test --all-features 2>&1

echo "FINAL_STATUS = SUCCESS"
