#!/bin/bash

# Activate nvm
export NVM_DIR="/root/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Use Node.js version 25
nvm use 25

# Navigate to the package directory
cd "packages/eslint-config-airbnb-base"

# Install project dependencies
npm install

# Run the tests
npm run travis