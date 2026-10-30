#!/bin/bash
set -e

# Print Node.js and npm versions for debugging
echo "Node.js version:"
node --version
echo "npm version:"
npm --version

# Install dependencies (if not already done)
npm install

# Run tests
echo "Running tests..."
npm run tests-only

echo "All tests completed successfully!"