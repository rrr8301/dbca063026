#!/usr/bin/env bash
set -e

cd /app

echo "Running: cargo test --all-targets --no-default-features --features crossterm,layout-cache"
cargo test --all-targets --no-default-features --features crossterm,layout-cache

echo ""
echo "Running: cargo test --all-targets --no-default-features --features crossterm"
cargo test --all-targets --no-default-features --features crossterm

echo ""
echo "FINAL_STATUS = SUCCESS"
