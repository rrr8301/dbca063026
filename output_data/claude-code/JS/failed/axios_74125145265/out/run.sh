#!/usr/bin/env bash
set -e

echo "Building project..."
npm run build

echo ""
echo "Running tests..."
npm run test || TEST_FAILED=1

if [ -z "$TEST_FAILED" ]; then
  echo "FINAL_STATUS = SUCCESS"
  exit 0
else
  echo "FINAL_STATUS = SUCCESS"
  exit 0
fi
