#!/usr/bin/env bash

set -e

cd /app

echo "Running tests..."
pnpm test || TEST_FAILED=1

echo "Running typecheck..."
pnpm typecheck || TYPECHECK_FAILED=1

if [ "$TEST_FAILED" = "1" ] || [ "$TYPECHECK_FAILED" = "1" ]; then
  echo "FINAL_STATUS = FAIL"
  exit 1
else
  echo "FINAL_STATUS = SUCCESS"
  exit 0
fi
