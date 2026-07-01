#!/usr/bin/env bash

set -e

cd /app

echo "=== Test Global ==="
pnpm test:global || TEST_GLOBAL_FAILED=1

echo ""
echo "=== Test Service ==="
pnpm test:service || TEST_SERVICE_FAILED=1

echo ""
echo "=== Test App ==="
pnpm test:app || TEST_APP_FAILED=1

if [ -n "$TEST_GLOBAL_FAILED" ] || [ -n "$TEST_SERVICE_FAILED" ] || [ -n "$TEST_APP_FAILED" ]; then
  echo ""
  echo "FINAL_STATUS = FAIL"
  exit 1
else
  echo ""
  echo "FINAL_STATUS = SUCCESS"
  exit 0
fi
