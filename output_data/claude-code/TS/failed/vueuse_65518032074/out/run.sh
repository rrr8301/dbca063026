#!/usr/bin/env bash
set -e

echo "=== Running unit tests with coverage ==="
pnpm run test:cov || TEST_UNIT_FAILED=1

if [ "$TEST_UNIT_FAILED" ]; then
  echo "Unit tests failed"
  echo "FINAL_STATUS = FAIL"
  exit 1
else
  echo "Tests ran successfully"
  echo "FINAL_STATUS = SUCCESS"
  exit 0
fi
