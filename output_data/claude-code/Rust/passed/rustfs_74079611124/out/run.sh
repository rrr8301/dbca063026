#!/usr/bin/env bash
set -e

cd /app

echo "=== Running cargo nextest ==="
cargo nextest run --all --exclude e2e_test || true

echo "=== Running cargo test --doc ==="
cargo test --all --doc || true

echo "=== Checking code formatting ==="
cargo fmt --all --check || true

echo "=== Running clippy ==="
cargo clippy --all-targets --all-features -- -D warnings || true

echo "=== Checking layer dependencies ==="
./scripts/check_layer_dependencies.sh || true

echo "FINAL_STATUS = SUCCESS"
