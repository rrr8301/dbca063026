#!/bin/bash

set -e

# Print Node and npm versions for debugging
echo "Node version: $(node --version)"
echo "npm version: $(npm --version)"
echo "pnpm version: $(pnpm --version)"

# Build the project with source maps enabled
echo "Building project with source maps..."
npm run build -- --sourceMap true

# Run tests with coverage in CI mode
echo "Running tests with coverage..."
npm run test:coverage -- --ci

echo "All tests completed successfully!"