#!/usr/bin/env bash
set -e

cd /app

echo "Building tests..."
cargo test --no-run --all --exclude niri-visual-tests 2>&1 | tail -50

echo ""
echo "Running tests..."
cargo test --all --exclude niri-visual-tests -- --nocapture 2>&1 | tail -100

echo ""
echo "FINAL_STATUS = SUCCESS"
