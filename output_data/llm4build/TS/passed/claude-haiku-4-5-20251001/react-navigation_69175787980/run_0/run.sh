#!/bin/bash

set -e

# Read Node.js version from .nvmrc
NODE_VERSION=$(cat .nvmrc)
echo "Node.js version from .nvmrc: $NODE_VERSION"

# Install the specified Node.js version using nvm or use system Node.js
# For simplicity, we'll use the system Node.js already installed
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