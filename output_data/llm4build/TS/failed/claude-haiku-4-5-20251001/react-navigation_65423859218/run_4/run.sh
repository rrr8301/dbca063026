#!/bin/bash
set -e

# Source nvm
export NVM_DIR=/root/.nvm
. "$NVM_DIR/nvm.sh"

# Use Node.js version from .nvmrc
NODE_VERSION=$(cat .nvmrc)
nvm use $NODE_VERSION

# Install dependencies
echo "Installing dependencies..."
yarn install --immutable

# Run unit tests with coverage
echo "Running unit tests..."
yarn test --maxWorkers=2 --coverage

echo "Tests completed successfully!"