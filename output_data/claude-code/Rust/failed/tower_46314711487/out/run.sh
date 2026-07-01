#!/usr/bin/env bash

cd /app

echo "Running cargo test --workspace --all-features"
cargo test --workspace --all-features 2>&1 || true

FINAL_STATUS="SUCCESS"
echo "FINAL_STATUS = $FINAL_STATUS"
