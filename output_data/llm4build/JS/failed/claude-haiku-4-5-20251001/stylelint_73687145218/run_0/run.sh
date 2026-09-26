#!/bin/bash
set -e

# Source nvm to ensure Node.js is available
export NVM_DIR=/root/.nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Verify Node.js and npm are available
node --version
npm --version

# Install latest npm globally
npm install --global npm

# Verify npm version after upgrade
npm --version

# Install project dependencies
npm ci

# Run tests
npm test