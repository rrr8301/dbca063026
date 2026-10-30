#!/bin/bash

set -e

# Print Node and pnpm versions for debugging
echo "Node.js version:"
node --version
echo "pnpm version:"
pnpm --version

# Install dependencies
echo "Installing dependencies with pnpm..."
pnpm install

# Run tests
echo "Running pnpm test..."
pnpm test

echo "All tests completed successfully!"