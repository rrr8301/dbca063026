#!/bin/bash

set -e

# Print Node and Yarn versions for debugging
echo "Node version: $(node --version)"
echo "Yarn version: $(yarn --version)"

# Clean build directory
echo "Cleaning build directory..."
rm -rf build

# Install root dependencies
echo "Installing root dependencies..."
yarn install --frozen-lockfile

# Install compiler dependencies
echo "Installing compiler dependencies..."
yarn --cwd compiler install --frozen-lockfile

# Run tests with shard 3/5
echo "Running tests (shard 3/5)..."
yarn test -r=stable --env=development --ci --shard=3/5

echo "Test execution completed."