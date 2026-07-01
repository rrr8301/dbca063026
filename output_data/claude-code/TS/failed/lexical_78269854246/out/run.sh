#!/usr/bin/env bash
set -e

cd /app

echo "Running pnpm test-unit..."
pnpm run test-unit

echo "FINAL_STATUS = SUCCESS"
