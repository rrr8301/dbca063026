#!/bin/bash

set -e

# Check if we're in a git repository with package.json
if [ ! -f "package.json" ]; then
    echo "Error: package.json not found in /workspace"
    echo "The repository code must be mounted or copied to /workspace"
    exit 1
fi

echo "Node.js version:"
node --version

echo "npm version:"
npm --version

echo "Installing dependencies..."
# Use npm ci if package-lock.json exists, otherwise use npm install
if [ -f "package-lock.json" ]; then
    npm ci
else
    echo "package-lock.json not found, using npm install instead"
    npm install
fi

echo "Running browserless tests..."
npm run test:browserless

echo "All tests completed!"