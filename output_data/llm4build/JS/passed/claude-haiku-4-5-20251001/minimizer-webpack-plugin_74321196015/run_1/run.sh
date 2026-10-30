#!/bin/bash

set -e

# Verify we're in the workspace
if [ ! -f "/workspace/package.json" ]; then
    echo "Error: package.json not found in /workspace"
    exit 1
fi

cd /workspace

# Install dependencies
# Use npm ci if package-lock.json exists, otherwise use npm install
echo "Installing dependencies..."
if [ -f "package-lock.json" ]; then
    npm ci
else
    echo "package-lock.json not found, using npm install instead"
    npm install
fi

# Run tests with coverage and CI flag
echo "Running tests with coverage..."
npm run test:coverage -- --ci

echo "Tests completed successfully!"