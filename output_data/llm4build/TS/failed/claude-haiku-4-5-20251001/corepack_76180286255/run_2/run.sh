#!/bin/bash
set -e

# Install project dependencies using Yarn
echo "Installing dependencies..."
corepack yarn install --immutable

# Build the project
echo "Building project..."
corepack yarn build

# Run tests with NOCK_ENV=replay
echo "Running tests..."
NOCK_ENV=replay corepack yarn test

echo "All tests completed successfully!"