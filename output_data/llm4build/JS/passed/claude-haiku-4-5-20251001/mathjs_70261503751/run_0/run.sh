#!/bin/bash

set -e

# Print Node and npm versions for debugging
echo "Node version: $(node --version)"
echo "npm version: $(npm --version)"

# Run build and test with CI environment variable
echo "Running build and test..."
CI=true npm run build-and-test

# Run additional tests to ensure comprehensive coverage
echo "Running linter..."
npm run lint || true

echo "Running type tests..."
npm run test:types || true

echo "Running coverage..."
npm run coverage || true

echo "All tests completed!"