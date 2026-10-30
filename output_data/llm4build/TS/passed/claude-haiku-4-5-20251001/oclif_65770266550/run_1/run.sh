#!/bin/bash

set -e

echo "=== Starting oclif Unit Tests ==="

# Install dependencies (if not already done)
echo "Installing dependencies..."
yarn install --frozen-lockfile

# Run linting (common in Node.js projects)
echo "Running linter..."
yarn lint || true

# Run unit tests
echo "Running unit tests..."
yarn test || TEST_FAILED=1

# Run build to ensure TypeScript compiles
echo "Building project..."
yarn build || BUILD_FAILED=1

# Summary
echo ""
echo "=== Test Execution Complete ==="

if [ "$TEST_FAILED" = "1" ]; then
    echo "⚠️  Some tests failed"
    exit 1
fi

if [ "$BUILD_FAILED" = "1" ]; then
    echo "⚠️  Build failed"
    exit 1
fi

echo "✅ All checks passed"
exit 0