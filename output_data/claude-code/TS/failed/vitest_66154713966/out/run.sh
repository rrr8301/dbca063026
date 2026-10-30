#!/usr/bin/env bash

set -e

cd /app

echo "=== Installing Playwright browsers ==="
pnpm exec playwright install --with-deps --only-shell

echo "=== Running tests ==="
VITEST_CI_BLOB_LABEL="ubuntu-latest-node-24" pnpm run test:ci

echo "=== Running examples ==="
pnpm run test:examples

echo "=== Running UI tests ==="
pnpm -C packages/ui test:ui

echo "FINAL_STATUS = SUCCESS"
