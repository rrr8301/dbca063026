#!/bin/bash
set -e

# Activate nvm
export NVM_DIR=/root/.nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Verify Node.js and npm are available
node --version
npm --version

# Install project dependencies
npm install

# Create separate require instance
npm run create-separate-require-instance

# Run tests with CI configuration
npm run test:ci