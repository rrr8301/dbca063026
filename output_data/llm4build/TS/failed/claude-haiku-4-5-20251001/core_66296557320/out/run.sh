#!/bin/bash

set -e

# Enable error handling to continue on test failures
trap 'TEST_FAILED=1' ERR

TEST_FAILED=0

echo "=========================================="
echo "Starting Vue.js Core E2E Test Suite"
echo "=========================================="

# Read Node.js version from .node-version file
if [ -f .node-version ]; then
    NODE_VERSION=$(cat .node-version | tr -d '\n' | xargs)
    echo "Node.js version specified: $NODE_VERSION"
fi

# Display Node.js and npm versions
echo "Current Node.js version: $(node --version)"
echo "Current npm version: $(npm --version)"
echo "Current pnpm version: $(pnpm --version)"

# Install project dependencies
echo "=========================================="
echo "Installing project dependencies..."
echo "=========================================="
pnpm install || { echo "Failed to install dependencies"; TEST_FAILED=1; }

# Install Puppeteer/Chromium
echo "=========================================="
echo "Installing Puppeteer and Chromium..."
echo "=========================================="
node node_modules/puppeteer/install.mjs || { echo "Failed to install Puppeteer"; TEST_FAILED=1; }

# Run e2e tests
echo "=========================================="
echo "Running E2E tests..."
echo "=========================================="
pnpm run test-e2e || { echo "E2E tests failed"; TEST_FAILED=1; }

# Verify treeshaking
echo "=========================================="
echo "Verifying treeshaking..."
echo "=========================================="
node scripts/verify-treeshaking.js || { echo "Treeshaking verification failed"; TEST_FAILED=1; }

echo "=========================================="
echo "Test suite completed"
echo "=========================================="

# Exit with appropriate code
if [ $TEST_FAILED -eq 1 ]; then
    echo "Some tests failed!"
    exit 1
fi

echo "All tests passed!"
exit 0