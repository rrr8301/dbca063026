#!/usr/bin/env bash

set -e

cd /app

# Run tests exactly as specified in the workflow
cargo test --verbose

# If we got here, tests ran successfully
echo "FINAL_STATUS = SUCCESS"
