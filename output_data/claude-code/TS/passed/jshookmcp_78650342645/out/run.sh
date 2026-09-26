#!/usr/bin/env bash

set -e

echo "=== Running Linters & Formatters ==="
pnpm run lint
pnpm run format:check
pnpm run typecheck

echo "=== Running Unit Tests with Coverage ==="
pnpm run test:coverage

echo "=== Building project ==="
pnpm run build

echo "FINAL_STATUS = SUCCESS"
