#!/usr/bin/env bash

set -e

cd /app

echo "Running pnpm build..."
pnpm build

echo "Running pnpm test..."
pnpm test

echo "Running pnpm run --filter @zod/resolution test:all..."
pnpm run --filter @zod/resolution test:all

echo "Running pnpm run --filter @zod/integration test:all..."
pnpm run --filter @zod/integration test:all

echo "FINAL_STATUS = SUCCESS"
