#!/bin/bash
set -e

# Get pnpm store directory
export STORE_PATH=$(corepack pnpm store path --silent)
echo "PNPM store path: $STORE_PATH"

# Install dependencies with frozen lockfile
echo "Installing dependencies..."
pnpm install --frozen-lockfile

# Generate registry index
echo "Generating registry index..."
node scripts/generate-domains-index.mjs

# Run linters & formatters
echo "Running linters..."
pnpm run lint

echo "Checking formatting..."
pnpm run format:check

echo "Running typecheck..."
pnpm run typecheck

# Run unit tests with coverage
echo "Running unit tests with coverage..."
pnpm run test:coverage

# Build project
echo "Building project..."
pnpm run build

echo "All checks and tests completed successfully!"