#!/bin/bash

set -e

# Log versions
echo "Node version:"
node --version
echo "npm version:"
npm -v

# Install npm dependencies (with retries as in original)
echo "Installing npm dependencies..."
npm install || (sleep 15 && npm install) || (sleep 15 && npm install)

# Build
echo "Running build..."
npm run build

# Test typings
echo "Running test:typings..."
npm run test:typings

# Test React
echo "Running test:react..."
npm run test:react

echo "All tests completed successfully!"