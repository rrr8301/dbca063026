#!/usr/bin/env bash
set -e

cd /app

# Run the exact test command from the workflow
cargo xtask test-backend termion

echo "FINAL_STATUS = SUCCESS"
