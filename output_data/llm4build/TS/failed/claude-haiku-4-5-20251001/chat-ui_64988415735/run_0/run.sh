#!/bin/bash

set -e

# Print Node and npm versions for debugging
echo "Node version: $(node --version)"
echo "npm version: $(npm --version)"

# Run tests
echo "Running tests..."
npm run test

echo "All tests completed successfully!"