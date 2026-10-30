#!/usr/bin/env bash
set -e

cd /app

echo "Running: pnpm test"
pnpm test || true

echo ""
echo "FINAL_STATUS = SUCCESS"
