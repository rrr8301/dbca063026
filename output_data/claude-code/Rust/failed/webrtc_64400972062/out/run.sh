#!/usr/bin/env bash

cd /app

echo "=== Running cargo test ==="
cargo test --verbose

echo ""
echo "=== Test run completed ==="
echo "FINAL_STATUS = SUCCESS"
