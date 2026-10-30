#!/bin/bash

set -e

# Enable error handling: continue on test failures but track exit code
TEST_FAILED=0

echo "=========================================="
echo "Starting Build & Test Pipeline"
echo "=========================================="

# Step 1: Install dependencies
echo ""
echo "Step 1: Installing dependencies with pnpm..."
pnpm i || { echo "Failed to install dependencies"; exit 1; }

# Step 2: Resolve Playwright version and install browser binaries
echo ""
echo "Step 2: Setting up Playwright..."
PLAYWRIGHT_VERSION=$(node -e "
  const fs = require('fs');
  const lockfile = fs.readFileSync('./pnpm-lock.yaml', 'utf8');
  const pattern = /playwright:\s+specifier: [\s\w\.^]+version: (\d+\.\d+\.\d+)/;
  const match = lockfile.match(pattern);
  if (match) {
    console.log(match[1]);
  } else {
    console.error('Failed to resolve Playwright version');
    process.exit(1);
  }
")

echo "Resolved Playwright version: $PLAYWRIGHT_VERSION"

# Install Playwright browser binaries and dependencies
pnpm exec playwright install --with-deps --only-shell || { echo "Failed to install Playwright"; exit 1; }

# Step 3: Build the project
echo ""
echo "Step 3: Building project..."
pnpm run build || { echo "Build failed"; TEST_FAILED=1; }

# Step 4: Run tests
echo ""
echo "Step 4: Running tests (pnpm run test:ci)..."
pnpm run test:ci || { echo "Tests failed"; TEST_FAILED=1; }

# Step 5: Run example tests
echo ""
echo "Step 5: Running example tests (pnpm run test:examples)..."
pnpm run test:examples || { echo "Example tests failed"; TEST_FAILED=1; }

echo ""
echo "=========================================="
if [ $TEST_FAILED -eq 0 ]; then
  echo "All tests passed!"
  echo "=========================================="
  exit 0
else
  echo "Some tests failed. See output above."
  echo "=========================================="
  exit 1
fi