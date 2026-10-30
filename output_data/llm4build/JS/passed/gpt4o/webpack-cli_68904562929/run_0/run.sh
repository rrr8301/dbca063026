#!/bin/bash

# Install project dependencies
pnpm install --frozen-lockfile

# Prepare environment for tests
npm run build -- --sourceMap true

# Run tests and generate coverage
# Ensure all tests run even if some fail
set +e
npm run test:coverage -- --ci
set -e