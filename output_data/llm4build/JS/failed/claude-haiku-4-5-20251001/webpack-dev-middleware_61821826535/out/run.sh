#!/bin/bash

set -e

# Print Node and npm versions for debugging
echo "Node version: $(node --version)"
echo "npm version: $(npm --version)"

# Install dependencies using npm ci (clean install, respects package-lock.json)
echo "Installing dependencies..."
npm ci

# Run tests with coverage in CI mode
# The --ci flag ensures proper CI behavior
echo "Running tests with coverage..."
npm run test:coverage -- --ci

echo "All tests completed successfully!"