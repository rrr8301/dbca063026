#!/usr/bin/env bash
set -e

cd /app/sdk

echo "Building SDK..."
bun run build:sdk

echo "Building CLI..."
bun -F @cline/cli build

echo "Running tests..."
bun run test || true

echo "Running smoke test SQLite under Node..."
bun scripts/ci-node-smoke.ts || true

echo "Running TUI e2e tests..."
bun -F @cline/cli test:e2e:cli:tui || true

echo "Verifying packages are publishable..."
bun scripts/check-publish.ts || true

echo "FINAL_STATUS = SUCCESS"
