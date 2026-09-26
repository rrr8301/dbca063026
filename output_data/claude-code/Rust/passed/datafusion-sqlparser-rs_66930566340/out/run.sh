#!/usr/bin/env bash

set -e

cd /app

# Run the test command from the workflow
cargo test --all-features

FINAL_STATUS=SUCCESS
echo "FINAL_STATUS = $FINAL_STATUS"
