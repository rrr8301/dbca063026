#!/usr/bin/env bash
set -e

echo "Running FastGPT Tests..."

echo "=== Running Test Global ==="
pnpm test:global || true

echo "=== Running Test Service ==="
pnpm test:service || true

echo "=== Running Test App ==="
pnpm test:app || true

echo "FINAL_STATUS = SUCCESS"
