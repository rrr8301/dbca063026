#!/usr/bin/env bash

set -e

cd /app

echo "Running: cargo test --workspace"
RUST_BACKTRACE=1 cargo test --workspace

echo ""
echo "FINAL_STATUS = SUCCESS"
