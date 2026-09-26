#!/bin/bash
set -e

# Activate nvm
export NVM_DIR=$HOME/.nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Verify Node.js is available
node --version
npm --version

# Install dependencies
npm ci

# Run tests
npm test