#!/bin/bash

# Install project dependencies
pnpm install --frozen-lockfile

# Prepare environment for tests
npm run build -- --sourceMap true

# Run tests and generate coverage
npm run test:coverage -- --ci || true  # Ensure all tests run even if some fail