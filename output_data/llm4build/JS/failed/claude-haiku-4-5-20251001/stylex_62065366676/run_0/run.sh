#!/bin/bash

set -e

# Print Node and Yarn versions for debugging
echo "Node version: $(node --version)"
echo "Yarn version: $(yarn --version)"

# Run the test suite for packages
echo "Running yarn test:packages..."
yarn test:packages

echo "All tests completed successfully!"