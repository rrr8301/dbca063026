#!/bin/bash

set -e

# Print Node version for verification
node --version
yarn --version

# Install root dependencies
echo "Installing root dependencies..."
yarn install --frozen-lockfile

# Install compiler dependencies
echo "Installing compiler dependencies..."
yarn --cwd compiler install --frozen-lockfile

# Run tests with exact command from YAML
echo "Running tests..."
yarn test -r=stable --env=production --ci --shard=4/5