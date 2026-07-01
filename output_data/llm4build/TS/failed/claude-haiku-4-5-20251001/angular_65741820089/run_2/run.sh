#!/bin/bash

set -e

# Activate nvm with interactive shell
export NVM_DIR=/root/.nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Use the Node version from .nvmrc
if [ -f .nvmrc ]; then
    NODE_VERSION=$(cat .nvmrc | xargs)
    echo "Using Node version from .nvmrc: $NODE_VERSION"
    nvm use $NODE_VERSION
else
    echo "Warning: .nvmrc file not found, using default Node version"
fi

# Verify Node and pnpm are available
echo "Node version:"
node --version
echo "npm version:"
npm --version
echo "pnpm version:"
pnpm --version

# Install node modules with frozen lockfile
echo "Installing dependencies..."
pnpm install --frozen-lockfile

# Run CI tests for framework
echo "Running CI tests..."
pnpm test:ci

echo "All tests completed successfully!"