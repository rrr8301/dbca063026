#!/bin/bash
set -e

# Install project dependencies
pnpm install --frozen-lockfile

# Run global tests
echo "Running global tests..."
pnpm test:global

# Run service tests
echo "Running service tests..."
pnpm test:service

echo "All tests completed successfully!"