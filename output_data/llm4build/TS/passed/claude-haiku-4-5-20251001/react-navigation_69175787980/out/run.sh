#!/bin/bash

set -e

# Read Node.js version from .nvmrc
NODE_VERSION=$(cat .nvmrc)
echo "Node.js version from .nvmrc: $NODE_VERSION"

# Verify Node.js is available
NODE_INSTALLED=$(node --version)
echo "Using Node.js: $NODE_INSTALLED"

# Verify yarn is available
yarn --version

# Install project dependencies
echo "Installing dependencies with yarn..."
yarn install --immutable

# Run unit tests with coverage
echo "Running unit tests with coverage..."
yarn test --maxWorkers=2 --coverage

echo "Unit tests completed successfully!"