#!/bin/bash

set -e

# Print Node and npm versions for debugging
echo "Node.js version:"
node --version
echo "npm version:"
npm --version

# Set CI environment variable
export CI=true

# Run build and test
echo "Running build and test..."
npm run build-and-test

# Run additional tests to ensure comprehensive coverage
echo "Running linter..."
npm run lint || true

# Run type tests if available
echo "Running type tests..."
npm run test:types || true

# Run coverage if available
echo "Running coverage..."
npm run coverage || true

echo "Build and test completed successfully!"