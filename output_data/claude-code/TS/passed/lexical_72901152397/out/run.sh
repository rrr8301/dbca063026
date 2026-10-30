#!/usr/bin/env bash
set -e

cd /app

echo "Running test-unit..."
pnpm run test-unit

FINAL_STATUS="SUCCESS"
echo "FINAL_STATUS = $FINAL_STATUS"
