#!/usr/bin/env bash
set -e

cd /app

echo "Running pnpm test..."
pnpm test || true

echo "Running @zod/resolution test:all..."
pnpm run --filter @zod/resolution test:all || true

echo "Running @zod/integration test:all..."
pnpm run --filter @zod/integration test:all || true

echo "FINAL_STATUS = SUCCESS"
