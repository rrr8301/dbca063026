#!/bin/bash

set -e

# Enable error handling: continue on test failures but track exit code
TEST_FAILED=0

echo "=========================================="
echo "Installing dependencies with pnpm..."
echo "=========================================="
pnpm i

echo "=========================================="
echo "Setting up Playwright browsers..."
echo "=========================================="
# Resolve Playwright version from pnpm-lock.yaml
PLAYWRIGHT_VERSION=$(node -e "
  const fs = require('fs');
  const lockfile = fs.readFileSync('./pnpm-lock.yaml', 'utf8');
  const pattern = /playwright:\s+specifier: [\s\w\.^]+version: (\d+\.\d+\.\d+)/;
  const match = lockfile.match(pattern);
  if (match && match[1]) {
    console.log(match[1]);
  } else {
    console.error('Failed to resolve Playwright version');
    process.exit(1);
  }
")

echo "Resolved Playwright version: $PLAYWRIGHT_VERSION"

# Set Playwright browsers path
export PLAYWRIGHT_BROWSERS_PATH="${PWD}/.cache/ms-playwright"
export VITEST_GENERATE_UI_TOKEN='true'

# Install Playwright dependencies and browsers
pnpm exec playwright install --with-deps --only-shell

echo "=========================================="
echo "Building project..."
echo "=========================================="
pnpm run build || { echo "Build failed"; TEST_FAILED=1; }

echo "=========================================="
echo "Running tests..."
echo "=========================================="
pnpm run test:ci || { echo "Tests failed"; TEST_FAILED=1; }

echo "=========================================="
echo "Running example tests..."
echo "=========================================="
pnpm run test:examples || { echo "Example tests failed"; TEST_FAILED=1; }

echo "=========================================="
echo "Test execution completed"
echo "=========================================="

if [ $TEST_FAILED -eq 1 ]; then
    echo "Some tests or build steps failed. Check output above."
    exit 1
fi

exit 0