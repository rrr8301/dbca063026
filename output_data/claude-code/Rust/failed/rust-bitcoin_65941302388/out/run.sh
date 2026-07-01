#!/usr/bin/env bash
set -e

echo "Starting 32-bit Rust test..."

cd /app

# Run the exact test command from the workflow
cargo test --target i686-unknown-linux-gnu

# If we get here, tests ran successfully
echo "FINAL_STATUS = SUCCESS"
