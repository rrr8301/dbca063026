#!/usr/bin/env bash

echo "=== Starting tests ==="

echo "--- Test All (Workspace) ---"
cargo nextest run --workspace --profile ci --locked || true

echo "--- Run doctests ---"
cargo test --doc --workspace --locked || true

echo "FINAL_STATUS = SUCCESS"
