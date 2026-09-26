#!/bin/bash

set -e

# Print Node and Yarn versions for debugging
echo "Node version: $(node --version)"
echo "Yarn version: $(yarn --version)"

# Run tests for packages
echo "Running package tests..."
yarn test:packages

echo "All tests completed successfully!"