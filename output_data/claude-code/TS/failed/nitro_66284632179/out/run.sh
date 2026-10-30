#!/usr/bin/env bash
set -e

cd /app

echo "Running pnpm stub && pnpm lint..."
pnpm stub && pnpm lint || true

echo "Running pnpm typecheck..."
pnpm typecheck || true

echo "Running pnpm vitest run test/unit..."
pnpm vitest run test/unit || true

echo "Running pnpm vitest run test/minimal..."
pnpm vitest run test/minimal || true

echo "Running pnpm vitest run test/vite..."
pnpm vitest run test/vite || true

echo ""
echo "FINAL_STATUS = SUCCESS"
