#!/bin/bash

set -e

# Print Node and pnpm versions for debugging
echo "Node version: $(node --version)"
echo "pnpm version: $(pnpm --version)"

# Install project dependencies
echo "Installing project dependencies..."
pnpm install

# Install Playwright browsers (Chromium)
echo "Installing Playwright Chromium..."
pnpm exec playwright install chromium

# Run tests in packages/vuetify
echo "Running tests in packages/vuetify..."
cd /workspace/packages/vuetify

# Run tests - continue even if tests fail so we can see all results
pnpm run test || TEST_FAILED=1

# Exit with appropriate code
if [ "$TEST_FAILED" = "1" ]; then
    echo "Tests failed!"
    exit 1
fi

echo "All tests passed!"
exit 0