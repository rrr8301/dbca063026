#!/bin/bash

# Install project dependencies
# Use --no-frozen-lockfile if pnpm-lock.yaml is absent
if [ ! -f pnpm-lock.yaml ]; then
  pnpm install --no-frozen-lockfile
else
  pnpm install --frozen-lockfile
fi

# Prepare environment for tests
npm run build -- --sourceMap true

# Run tests and generate coverage
npm run test:coverage -- --ci