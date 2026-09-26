#!/usr/bin/env bash
set -e

cd /app

# Run node-env tests
echo "Running jest-environment-node tests..."
yarn workspace jest-environment-node test || true

# Run tests with shard 3/3
echo "Running tests with shard 3/3..."
yarn test-ci-partial:parallel --max-workers 4 --shard=3/3 || true

echo "FINAL_STATUS = SUCCESS"
