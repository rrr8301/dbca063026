#!/bin/bash

set -e

# Install npm dependencies with CI flag
echo "Installing npm dependencies..."
CI=true npm install

# Install ESLint@10.x and @eslint/js@10.x as dev dependencies
echo "Installing ESLint@10.x and @eslint/js@10.x..."
npm install -D eslint@10.x @eslint/js@10.x

# Run tests
echo "Running tests..."
npm run test

echo "All tests completed successfully!"