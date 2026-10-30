#!/usr/bin/env bash
set -e

echo "Starting Rust unit tests..."
cd /app

# Run the exact test command from the justfile
cargo test --lib --bins --workspace --features unit_tests --quiet

# If tests ran successfully
echo "FINAL_STATUS = SUCCESS"
