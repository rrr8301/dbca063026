#!/bin/bash

set -e

# Print Node and npm versions for debugging
echo "Node version: $(node --version)"
echo "npm version: $(npm --version)"
echo "pnpm version: $(pnpm --version)"

# Install project dependencies using nci (ni command)
echo "Installing dependencies..."
nci

# Build the project
echo "Building project..."
nr build

# Run tests with coverage
echo "Running tests with coverage..."
nr test --coverage

echo "All tests completed successfully!"