#!/bin/bash
set -e

# Activate nvm
export NVM_DIR=/root/.nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Use Node.js 21
nvm use 21

# Navigate to the package directory
cd packages/eslint-config-airbnb-base

# Install npm dependencies
npm install

# Install eslint@8 (no-save as per the workflow)
npm install --no-save "eslint@8"

# Print eslint version (for verification)
node -pe "require('eslint/package.json').version"

# Run the test suite
npm run travis