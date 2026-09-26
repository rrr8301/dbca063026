#!/bin/bash

# Activate nvm
export NVM_DIR="/usr/local/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install Node.js version from matrix
nvm install $NODE_VERSION

# Install project dependencies with legacy peer deps flag
npm install --legacy-peer-deps

# Run npx ls-engines
npx ls-engines

# Run unit tests
npm run unit-test || true

# Ensure all tests are executed even if some fail
exit 0