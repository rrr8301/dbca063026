#!/bin/bash

# Check if pnpm-lock.yaml exists, if not, install without frozen-lockfile
if [ ! -f pnpm-lock.yaml ]; then
  echo "pnpm-lock.yaml not found, installing without frozen-lockfile"
  pnpm install --no-frozen-lockfile || true
else
  # Install project dependencies
  pnpm install --frozen-lockfile || true
fi

# Compile TypeScript files
pnpm tsc || exit 1

# Prepare environment for tests
npm run build -- --sourceMap true || exit 1

# Run tests and generate coverage
# Ensure all tests run even if some fail
set +e
npm run test:coverage -- --ci || true
set -e