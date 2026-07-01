#!/usr/bin/env bash
set -e

cd /app

echo "=========================================="
echo "Running: cargo build --tests --features internal"
echo "=========================================="
cargo build --tests --features internal

echo "=========================================="
echo "Running: cargo test --features internal"
echo "=========================================="
cargo test --features internal

echo "=========================================="
echo "Running: cargo test (in clippy_lints)"
echo "=========================================="
cd /app/clippy_lints
cargo test

echo "=========================================="
echo "Running: cargo test (in clippy_utils)"
echo "=========================================="
cd /app/clippy_utils
cargo test

echo "=========================================="
echo "Running: cargo test (in rustc_tools_util)"
echo "=========================================="
cd /app/rustc_tools_util
cargo test

echo "=========================================="
echo "Running: cargo test (in clippy_dev)"
echo "=========================================="
cd /app/clippy_dev
cargo test

echo "=========================================="
echo "Running: .github/driver.sh"
echo "=========================================="
cd /app
OS=Linux .github/driver.sh

echo ""
echo "=========================================="
echo "FINAL_STATUS = SUCCESS"
echo "=========================================="
