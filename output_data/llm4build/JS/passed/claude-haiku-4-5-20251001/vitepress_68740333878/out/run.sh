#!/bin/bash

set -e

# Print Node and pnpm versions for debugging
echo "Node version: $(node --version)"
echo "npm version: $(npm --version)"
echo "pnpm version: $(pnpm --version)"

# Install project dependencies
# PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1 prevents automatic browser downloads during pnpm install
echo "Installing dependencies..."
PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1 pnpm install

# Install Playwright chromium browser
echo "Installing Playwright chromium..."
pnpm playwright install chromium

# Run checks (linting, type checking, tests)
echo "Running checks..."
pnpm check

echo "All tests completed successfully!"