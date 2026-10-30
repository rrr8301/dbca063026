#!/bin/bash

# Activate nvm and use Node.js version 21
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm use 21

# Navigate to the package directory
cd packages/eslint-config-airbnb-base

# Install project dependencies
npm install

# Install specific eslint version
npm install --no-save eslint@8

# Check eslint version
node -pe "require('eslint/package.json').version"

# Run tests
npm run travis