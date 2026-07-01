#!/bin/bash

# Install project dependencies
pnpm install

# Build the project
pnpm build

# Run tests
set +e  # Continue on errors
pnpm test
pnpm run --filter @zod/resolution test:all
pnpm run --filter @zod/integration test:all
set -e  # Stop on errors