#!/bin/bash

# Activate corepack
corepack enable

# Install project dependencies
pnpm install

# Build the project
pnpm build

# Typecheck the project
pnpm typecheck

# Run tests
set +e  # Continue executing even if some tests fail
pnpm vitest run test/unit
pnpm vitest run test/minimal
pnpm vitest run test/vite
set -e  # Re-enable exit on error