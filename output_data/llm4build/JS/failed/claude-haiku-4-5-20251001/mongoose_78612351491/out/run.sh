#!/bin/bash
set -e

# Print Node.js and npm versions for debugging
echo "Node.js version:"
node --version
echo "npm version:"
npm --version

# Install project dependencies
echo "Installing npm dependencies..."
npm install

# Create separate require instance (as per workflow)
echo "Creating separate require instance..."
npm run create-separate-require-instance

# Run tests with coverage
echo "Running tests..."
npm run test:ci

echo "All tests completed successfully!"