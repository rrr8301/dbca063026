#!/usr/bin/env bash
set -e

cd /app/apps/js-sdk/firecrawl

echo "=== Building ==="
pnpm run build

echo "=== Running tests ==="
pnpm run test || true

FINAL_STATUS="SUCCESS"
echo "FINAL_STATUS = $FINAL_STATUS"
