#!/bin/bash

# Install project dependencies
pnpm install --frozen-lockfile

# Generate registry index
node scripts/generate-domains-index.mjs

# Run linters, formatters, and typecheck
pnpm run lint
pnpm run format:check
pnpm run typecheck

# Run unit tests with coverage
pnpm run test:coverage