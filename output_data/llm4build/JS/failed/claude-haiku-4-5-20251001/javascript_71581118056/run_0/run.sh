#!/bin/bash
set -e

# Activate nvm
export NVM_DIR=/root/.nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Navigate to the package directory
cd packages/eslint-config-airbnb-base

# Install npm dependencies
npm install

# Install eslint@7 as a no-save dependency
npm install --no-save "eslint@7"

# Print eslint version
node -pe "require('eslint/package.json').version"

# Run the test suite
npm run travis