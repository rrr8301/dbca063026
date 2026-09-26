#!/bin/bash
set -e

# Use the symlinked node and npm from /usr/local/bin
export PATH=/usr/local/bin:$PATH

# Verify Node.js and npm are available
node --version
npm --version

# Install project dependencies
npm install

# Create separate require instance
npm run create-separate-require-instance

# Run tests with CI configuration
npm run test:ci