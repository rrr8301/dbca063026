#!/bin/bash
set -e

# Set environment variable
export PUPPETEER_SKIP_DOWNLOAD=true

# Navigate to core directory (based on installation file paths)
cd /workspace/core

# Read Node version from .node-version file
NODE_VERSION=$(cat .node-version)
echo "Using Node.js version: $NODE_VERSION"

# Install dependencies using pnpm
echo "Installing dependencies with pnpm..."
pnpm install

# Run compiler unit tests
echo "Running compiler unit tests..."
pnpm run test-unit compiler

# Run ssr unit tests
echo "Running ssr unit tests..."
pnpm run test-unit server-renderer

echo "All tests completed successfully!"