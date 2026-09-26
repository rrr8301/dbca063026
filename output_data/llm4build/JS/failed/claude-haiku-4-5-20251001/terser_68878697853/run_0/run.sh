#!/bin/bash

set -e

# Print Node and npm versions for debugging
echo "Node.js version:"
node --version
echo "npm version:"
npm --version

# Install dependencies
echo "Installing dependencies..."
npm ci

# Build the app
echo "Building the app..."
npm run build --if-present || true

# Run compress tests
echo "Running compress tests..."
npm run test:compress || TEST_COMPRESS_FAILED=1

# Run mocha tests with TERSER_TEST_ALL environment variable
echo "Running mocha tests..."
export TERSER_TEST_ALL=1
npm run test:mocha || TEST_MOCHA_FAILED=1

# Report test results
if [ "$TEST_COMPRESS_FAILED" = "1" ] || [ "$TEST_MOCHA_FAILED" = "1" ]; then
    echo "Some tests failed!"
    exit 1
fi

echo "All tests passed!"
exit 0