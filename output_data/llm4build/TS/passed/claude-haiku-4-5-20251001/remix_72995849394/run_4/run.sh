#!/bin/bash

set -e

# Print commands for debugging
set -x

# Navigate to workspace
cd /workspace

# Install project dependencies
echo "Installing project dependencies..."
pnpm install --frozen-lockfile

# Build the project (compile TypeScript)
echo "Building project..."
pnpm build

# Get Playwright version
echo "Getting Playwright version..."
PLAYWRIGHT_VERSION=$(pnpm --filter @remix-run/component exec playwright --version | cut -d ' ' -f2)
echo "Playwright version: $PLAYWRIGHT_VERSION"

# Install Playwright browsers with dependencies
echo "Installing Playwright browsers..."
pnpm --filter @remix-run/component exec playwright install --with-deps

# Run tests
echo "Running tests..."
pnpm test

echo "All tests completed successfully!"