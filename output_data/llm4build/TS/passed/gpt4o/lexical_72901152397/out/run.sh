#!/bin/bash

# Activate environment variables if needed
export CI=true

# Install project dependencies
pnpm install --frozen-lockfile

# Run tests and ensure all tests are executed
set +e  # Do not exit immediately on error
pnpm run ci-check
pnpm run build
pnpm run build-www
pnpm run --filter @lexical/website build
pnpm run --filter lexical-playground build-vercel
pnpm run test-unit
set -e  # Re-enable exit on error