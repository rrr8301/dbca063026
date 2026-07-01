#!/bin/bash

set -e

# Output Node and NPM versions
echo "Node.js version: $(node -v)"
echo "NPM version: $(npm -v)"

# Configure npm loglevel
npm config set loglevel error

# Install dependencies
echo "Installing dependencies..."
npm install

# Run tests
echo "Running tests..."
npm run test-ci

echo "Tests completed successfully!"