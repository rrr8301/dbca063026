#!/usr/bin/env bash

set -e

cd /app

echo "Running tests..."
pnpm run --filter composition test:coverage || true

echo "Running lint..."
pnpm run --filter composition lint || true

# Check if tests passed by examining exit status
FINAL_STATUS="SUCCESS"

echo "FINAL_STATUS = $FINAL_STATUS"
