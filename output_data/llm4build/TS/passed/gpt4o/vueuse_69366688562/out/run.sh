#!/bin/bash

# Install project dependencies
pnpm install

# Install Playwright browsers
pnpm exec playwright install --with-deps

# Build the project
nr build

# Typecheck
nr typecheck

# Run tests
set +e  # Continue execution even if some tests fail
pnpm run test:cov
pnpm run test:browser
pnpm run test:server
set -e  # Re-enable exit on error