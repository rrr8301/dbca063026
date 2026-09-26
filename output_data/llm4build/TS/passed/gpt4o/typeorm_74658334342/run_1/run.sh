#!/bin/bash

# Install project dependencies
pnpm install

# Build the project to compile TypeScript files
pnpm run build

# Copy configuration file
cp .github/workflows/test/sqlite.ormconfig.json ormconfig.json

# Run tests
pnpm exec c8 pnpm run test:ci