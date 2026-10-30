#!/usr/bin/env bash
set -e

echo "=== Codegen checks (rust-analyzer) ==="
cargo codegen --check

echo "=== Run tests ==="
cargo nextest run --no-fail-fast --hide-progress-bar --status-level fail

echo "=== Install cargo-machete ==="
cargo install cargo-machete

echo "=== Run cargo-machete ==="
cargo machete

echo "FINAL_STATUS = SUCCESS"
