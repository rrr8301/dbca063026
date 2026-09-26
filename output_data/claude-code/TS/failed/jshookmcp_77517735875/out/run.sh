#!/usr/bin/env bash
set -e

cd /app

echo "=== Running Linters & Formatters ==="
pnpm run lint || true
pnpm run format:check || true
pnpm run typecheck || true

echo "=== Running Unit Tests with Coverage ==="
pnpm run test:coverage || TEST_FAILED=1

echo "=== Building project ==="
pnpm run build || BUILD_FAILED=1

if [ -z "$TEST_FAILED" ] && [ -z "$BUILD_FAILED" ]; then
  echo "FINAL_STATUS = SUCCESS"
  exit 0
else
  echo "FINAL_STATUS = FAIL"
  exit 1
fi
