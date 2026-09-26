#!/bin/bash

set -e

# Clone the repository (assuming it's passed as an environment variable or argument)
# For local testing, the repo should be mounted or copied
if [ ! -d ".git" ]; then
    echo "Repository not found. Assuming code is already in /workspace"
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