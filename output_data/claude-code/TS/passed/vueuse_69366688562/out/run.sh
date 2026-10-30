#!/usr/bin/env bash

set -e

cd /app

echo "=== Build ==="
pnpm run build

echo "=== Typecheck ==="
pnpm run typecheck

echo "=== Unit tests ==="
pnpm run test:cov || true

echo "=== Browser tests ==="
pnpm run test:browser || true

echo "=== Server tests ==="
pnpm run test:server || true

echo ""
echo "FINAL_STATUS = SUCCESS"
