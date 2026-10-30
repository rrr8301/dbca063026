#!/bin/bash

# Source the bashrc to ensure PNPM_HOME is in the PATH
source /root/.bashrc

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