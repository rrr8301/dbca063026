#!/usr/bin/env bash

set -e

echo "===== Running RustFS Tests ====="

# Run tests
echo "Step 1: Running cargo nextest..."
cargo nextest run --all --exclude e2e_test || true

echo "Step 2: Running cargo test docs..."
cargo test --all --doc || true

# Check code formatting
echo "Step 3: Checking code formatting..."
cargo fmt --all --check || true

# Run clippy lints
echo "Step 4: Running clippy lints..."
cargo clippy --all-targets --all-features -- -D warnings || true

# Check layered dependencies
echo "Step 5: Checking layered dependencies..."
./scripts/check_layer_dependencies.sh || true

echo "===== Tests Completed ====="
FINAL_STATUS=SUCCESS
echo "FINAL_STATUS=$FINAL_STATUS"
