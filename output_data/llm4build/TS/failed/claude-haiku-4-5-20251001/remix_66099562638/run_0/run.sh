#!/bin/bash

set -e

# Print Node and pnpm versions for debugging
echo "Node.js version: $(node --version)"
echo "pnpm version: $(pnpm --version)"

# Install dependencies with pnpm (frozen lockfile for reproducibility)
echo "Installing dependencies..."
pnpm install --frozen-lockfile

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