#!/bin/bash

set -e

# Activate nvm
export NVM_DIR=/root/.nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Use the Node version from .nvmrc
NODE_VERSION=$(cat .nvmrc)
nvm use $NODE_VERSION

# Verify Node and pnpm are available
node --version
npm --version
pnpm --version

# Install node modules with frozen lockfile
echo "Installing dependencies..."
pnpm install --frozen-lockfile

# Run CI tests for framework
echo "Running CI tests..."
pnpm test:ci

echo "All tests completed successfully!"