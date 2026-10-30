#!/bin/bash

set -e

# Read Node.js version from .nvmrc if it exists
if [ -f .nvmrc ]; then
    NODE_VERSION=$(cat .nvmrc | tr -d 'v')
    echo "Node.js version from .nvmrc: $NODE_VERSION"
fi

# Install Playwright Chromium
echo "Installing Playwright Chromium..."
pnpm exec playwright install chromium

# Run tests in packages/vuetify
echo "Running tests in packages/vuetify..."
cd ./packages/vuetify
pnpm run test

echo "Tests completed successfully!"