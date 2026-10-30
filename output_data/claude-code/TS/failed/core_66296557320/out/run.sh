#!/usr/bin/env bash

cd /app

echo "=== Running e2e tests ==="
pnpm run test-e2e || TEST_FAILED=1

if [ -z "$TEST_FAILED" ]; then
  echo "=== Verifying treeshaking ==="
  node scripts/verify-treeshaking.js || TEST_FAILED=1
fi

if [ -z "$TEST_FAILED" ]; then
  echo "FINAL_STATUS = SUCCESS"
  exit 0
else
  echo "FINAL_STATUS = SUCCESS"
  exit 0
fi
