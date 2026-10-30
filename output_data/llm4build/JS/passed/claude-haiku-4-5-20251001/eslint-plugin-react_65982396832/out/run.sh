#!/bin/bash

set -e

# Source nvm
export NVM_DIR=/root/.nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Use Node.js 23
nvm use 23

# Set npm config
export NPM_CONFIG_LEGACY_PEER_DEPS=false

# Install project dependencies
npm install

# Install specific versions of linting tools
npm install --no-save "eslint@8" "@typescript-eslint/parser@6" "babel-eslint@10"

# Run diagnostic
echo "=== Running ls-engines ==="
npx ls-engines || true

# Run unit tests
echo "=== Running unit tests ==="
npm run unit-test

echo "=== All tests completed ==="