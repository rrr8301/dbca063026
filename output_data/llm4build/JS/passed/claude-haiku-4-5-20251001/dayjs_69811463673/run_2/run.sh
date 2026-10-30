#!/bin/bash
set -e

# Activate nvm
export NVM_DIR="/usr/local/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Verify Node.js and npm are available
node --version
npm --version

# Run linting
echo "Running linting..."
npm run lint

# Run tests
echo "Running tests..."
npm test

echo "All checks passed!"