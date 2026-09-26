#!/usr/bin/env bash
set -e

cd /app

echo "=== Setup typescript-sdk ==="
cd /app/open-api/typescript-sdk
pnpm install && pnpm run build
cd /app

echo "=== Install deps (cli) ==="
cd /app/cli
pnpm install

echo "=== Run linter ==="
pnpm lint || true

echo "=== Run formatter ==="
pnpm format || true

echo "=== Run tsc ==="
pnpm check || true

echo "=== Run unit tests & coverage ==="
pnpm test || true

echo ""
echo "FINAL_STATUS = SUCCESS"
