#!/bin/bash

set -e

# Print Node and npm versions for debugging
echo "Node version: $(node --version)"
echo "npm version: $(npm --version)"

# Run the test suite
echo "Running tests..."
npm run tests-only

echo "All tests completed successfully!"