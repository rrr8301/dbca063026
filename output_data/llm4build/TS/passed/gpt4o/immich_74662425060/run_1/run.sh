#!/bin/bash

# Navigate to the CLI directory
cd /app/cli

# Install project dependencies
pnpm install

# Setup typescript-sdk
cd /app/open-api/typescript-sdk
pnpm install && pnpm run build

# Return to CLI directory
cd /app/cli

# Run linter, formatter, type-checker, and unit tests
pnpm lint
pnpm format
pnpm check
pnpm test