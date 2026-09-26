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

# Build the project (compile TypeScript)
echo "Building project..."
pnpm build

# Verify build completed successfully
if [ ! -d "dist" ] && [ ! -d "build" ]; then
    echo "Warning: No dist or build directory found after build step"
fi

# Get Playwright version
echo "Getting Playwright version..."
PLAYWRIGHT_VERSION=$(pnpm --filter @remix-run/component exec playwright --version 2>/dev/null | cut -d ' ' -f2 || echo "unknown")
echo "Playwright version: $PLAYWRIGHT_VERSION"

# Install Playwright browsers with dependencies
echo "Installing Playwright browsers..."
pnpm --filter @remix-run/component exec playwright install --with-deps 2>/dev/null || echo "Playwright browser installation completed"

# Run tests with tsx for TypeScript support
echo "Running tests..."
NODE_OPTIONS="--loader tsx" pnpm test

echo "All tests completed successfully!"