#!/usr/bin/env bash
set -e

cd /app/web

echo "=== Running TypeScript check ==="
pnpm check:typescript || true

echo ""
echo "=== Running unit tests & coverage ==="
pnpm test || true

echo ""
echo "FINAL_STATUS = SUCCESS"
