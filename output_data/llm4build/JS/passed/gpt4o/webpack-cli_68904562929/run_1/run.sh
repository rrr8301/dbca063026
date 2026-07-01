#!/bin/bash

# Check if pnpm-lock.yaml exists, if not, install without frozen-lockfile
if [ ! -f pnpm-lock.yaml ]; then
  echo "pnpm-lock.yaml not found, installing without frozen-lockfile"
  pnpm install --no-frozen-lockfile
else
  # Install project dependencies
  pnpm install --frozen-lockfile
fi

# Prepare environment for tests
npm run build -- --sourceMap true

# Run tests and generate coverage
# Ensure all tests run even if some fail
set +e
npm run test:coverage -- --ci
set -e