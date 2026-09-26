#!/bin/bash

set -e

# Print Node and npm versions for debugging
echo "Node version: $(node --version)"
echo "npm version: $(npm --version)"

# Install dependencies using npm ci (clean install)
echo "Installing dependencies..."
npm ci

# Build project
echo "Building project..."
npm run build

# Run unit tests
echo "Running unit tests..."
npm run test:node || TEST_NODE_FAILED=1

# Run package tests
echo "Running package tests..."
npm run test:package || TEST_PACKAGE_FAILED=1

# Report test results
if [ "$TEST_NODE_FAILED" = "1" ] || [ "$TEST_PACKAGE_FAILED" = "1" ]; then
    echo "Some tests failed!"
    exit 1
fi

echo "All tests passed!"
exit 0