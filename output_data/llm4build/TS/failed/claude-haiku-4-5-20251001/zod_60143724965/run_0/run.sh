#!/bin/bash

set -e

# Print Node and pnpm versions for debugging
echo "Node version: $(node --version)"
echo "npm version: $(npm --version)"
echo "pnpm version: $(pnpm --version)"

# Install project dependencies
echo "Installing dependencies with pnpm..."
pnpm install

# Add TypeScript latest
echo "Adding TypeScript latest..."
pnpm add typescript@latest -w

# Build the project
echo "Building project..."
pnpm build

# Run main tests
echo "Running main tests..."
pnpm test || TEST_FAILED=1

# Run resolution tests
echo "Running resolution tests..."
pnpm run --filter @zod/resolution test:all || TEST_FAILED=1

# Run integration tests
echo "Running integration tests..."
pnpm run --filter @zod/integration test:all || TEST_FAILED=1

# Exit with failure if any test failed
if [ "$TEST_FAILED" = "1" ]; then
    echo "Some tests failed!"
    exit 1
fi

echo "All tests passed!"
exit 0