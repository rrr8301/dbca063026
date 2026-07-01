#!/bin/bash

set -e

# Check if package.json exists
if [ ! -f "package.json" ]; then
    echo "Error: package.json not found in /workspace"
    exit 1
fi

# Display Node.js and npm versions
echo "Node.js version:"
node --version
echo "npm version:"
npm --version

# Install project dependencies
echo "Installing project dependencies..."
npm install

# Install ESLint@10.x as dev dependency
echo "Installing ESLint@10.x..."
npm install -D eslint@10.x

# Run tests
echo "Running tests..."
CI=true npm run test

echo "All tests completed!"