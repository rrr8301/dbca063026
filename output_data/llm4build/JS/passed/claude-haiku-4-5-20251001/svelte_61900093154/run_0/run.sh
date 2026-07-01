#!/bin/bash

set -e

# Print commands for debugging
set -x

# Install project dependencies with frozen lockfile
pnpm install --frozen-lockfile

# Install Playwright chromium browser
pnpm playwright install chromium

# Run tests
pnpm test

echo "All tests completed successfully!"