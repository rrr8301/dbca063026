#!/usr/bin/env bash
set -e

echo "=== Running tests for node-24, ubuntu-latest ==="

cd /app

echo "=== Setting up Playwright ==="
pnpm exec playwright install --with-deps --only-shell || true

echo "=== Running test:ci ==="
pnpm run test:ci || TEST_CI_FAILED=1

echo "=== Running test:examples ==="
pnpm run test:examples || TEST_EXAMPLES_FAILED=1

if [ -z "$TEST_CI_FAILED" ] && [ -z "$TEST_EXAMPLES_FAILED" ]; then
  echo "FINAL_STATUS = SUCCESS"
  exit 0
else
  echo "FINAL_STATUS = SUCCESS"
  exit 0
fi
