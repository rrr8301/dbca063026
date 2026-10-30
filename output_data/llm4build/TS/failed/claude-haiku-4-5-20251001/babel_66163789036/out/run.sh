#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Install dependencies using Yarn
echo "Installing dependencies..."
yarn install

# Set environment variables for tests
export BABEL_ENV=test
export BABEL_COVERAGE=true

# Run tests with coverage
echo "Running tests with coverage..."
yarn c8 jest --ci

# Run ESM tests
echo "Running ESM tests..."
yarn test:esm

echo "All tests completed successfully!"