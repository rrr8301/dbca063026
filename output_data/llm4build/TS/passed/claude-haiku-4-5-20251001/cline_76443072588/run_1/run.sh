#!/bin/bash
set -e

# Install dependencies
echo "Installing dependencies with bun..."
bun install

# Build SDK
echo "Building SDK..."
bun run build:sdk

# Build CLI
echo "Building CLI..."
bun -F @cline/cli build

# Run Tests
echo "Running tests..."
bun run test

# Smoke test SQLite under Node
echo "Running smoke test for SQLite under Node..."
bun scripts/ci-node-smoke.ts

# Run TUI e2e tests
echo "Running TUI e2e tests..."
bun -F @cline/cli test:e2e:cli:tui

# Verify packages are publishable
echo "Verifying packages are publishable..."
bun scripts/check-publish.ts

echo "All tests completed successfully!"