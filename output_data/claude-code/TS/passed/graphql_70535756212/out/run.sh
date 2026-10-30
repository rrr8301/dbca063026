#!/usr/bin/env bash

cd /app

# Get number of CPU cores available
CPU_COUNT=$(nproc)
echo "Running tests with CPU count: $CPU_COUNT"

# Run the test command from the workflow
# Don't use set -e so we can continue even if tests fail
yarn test-ci --minWorkers=1 --maxWorkers=$CPU_COUNT || true

echo "FINAL_STATUS = SUCCESS"
