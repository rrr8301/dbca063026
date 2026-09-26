#!/usr/bin/env bash
set -e

echo "Starting tests..."

pnpm build
pnpm typecheck
pnpm vitest run test/unit
pnpm vitest run test/minimal
pnpm vitest run test/vite

echo "FINAL_STATUS = SUCCESS"
