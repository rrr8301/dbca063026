#!/bin/bash

set -e

# Print commands for debugging
set -x

# Navigate to workspace
cd /workspace

# Install project dependencies
echo "Installing project dependencies..."
pnpm install --frozen-lockfile

# Install tsx globally for TypeScript execution support
echo "Installing tsx for TypeScript support..."
pnpm add -g tsx

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