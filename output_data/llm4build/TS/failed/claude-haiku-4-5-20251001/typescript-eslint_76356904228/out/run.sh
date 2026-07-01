#!/bin/bash

set -e

# Install dependencies
echo "Installing dependencies..."
pnpm install --frozen-lockfile
pnpm run check-clean-workspace-after-install

# Build AST Spec (always run as per prepare-build action)
echo "Building AST Spec..."
pnpm exec nx run types:build

# Build all packages
echo "Building all packages..."
pnpm exec nx run-many --target=build --parallel --exclude=website --exclude=website-eslint

# Run unit tests with coverage for eslint-plugin
echo "Running unit tests with coverage..."
pnpm exec nx test eslint-plugin -- --shard=1/4 --coverage

echo "All tests completed successfully!"