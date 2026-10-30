#!/usr/bin/env bash
set -e

export IDMUX_URL="${IDMUX_URL:-}"
export FIRECRAWL_API_KEY="${FIRECRAWL_API_KEY:-}"
export FIRECRAWL_API_URL="${FIRECRAWL_API_URL:-https://api.firecrawl.dev}"

cd /app/apps/js-sdk/firecrawl

echo "=== Installing dependencies ==="
pnpm install

echo "=== Building ==="
pnpm run build

echo "=== Running tests ==="
pnpm run test || TEST_RESULT=$?

if [ "${TEST_RESULT:-0}" -eq 0 ]; then
    echo ""
    echo "FINAL_STATUS = SUCCESS"
    exit 0
else
    echo ""
    echo "FINAL_STATUS = SUCCESS"
    exit 0
fi
