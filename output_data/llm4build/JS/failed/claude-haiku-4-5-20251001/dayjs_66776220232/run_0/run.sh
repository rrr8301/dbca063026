#!/bin/bash
set -e

# Source nvm
export NVM_DIR=/home/testuser/.nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Verify Node.js and npm are available
node --version
npm --version

# Install dependencies
npm install

# Run linting
npm run lint

# Run tests
npm test