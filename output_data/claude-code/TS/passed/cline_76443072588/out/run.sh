#!/usr/bin/env bash
set -e

cd /app/sdk

echo "=== Building SDK ==="
bun run build:sdk

echo "=== Building CLI ==="
bun -F @cline/cli build

echo "=== Running Tests ==="
bun run test

echo "=== Running Node.js SQLite Smoke Test ==="
bun scripts/ci-node-smoke.ts

echo "=== Running TUI e2e Tests ==="
bun -F @cline/cli test:e2e:cli:tui

echo "=== Verifying Packages are Publishable ==="
bun scripts/check-publish.ts

echo "FINAL_STATUS = SUCCESS"
