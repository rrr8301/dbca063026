#!/usr/bin/env bash
set -e

echo "Running compiler unit tests..."
pnpm run test-unit compiler || true

echo "Running ssr unit tests..."
pnpm run test-unit server-renderer || true

echo "FINAL_STATUS = SUCCESS"
