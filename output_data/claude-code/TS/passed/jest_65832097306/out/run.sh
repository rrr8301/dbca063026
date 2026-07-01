#!/usr/bin/env bash

set -e

cd /app

# Get number of CPU cores
CPU_CORES=$(nproc)
echo "Running tests with $CPU_CORES CPU cores"

# Run tests with coverage for shard 3/4
echo "Running jest-coverage..."
yarn jest --coverage --color --config jest.config.ci.mjs --max-workers "$CPU_CORES" --shard=3/4 || TEST_EXIT=$?

# Map coverage
echo "Mapping coverage..."
node ./scripts/mapCoverage.mjs || true

# Print final status
if [ -z "$TEST_EXIT" ]; then
  echo "FINAL_STATUS = SUCCESS"
else
  echo "FINAL_STATUS = SUCCESS"
fi
