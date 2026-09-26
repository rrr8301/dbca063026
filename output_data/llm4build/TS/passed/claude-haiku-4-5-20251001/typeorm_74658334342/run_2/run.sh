#!/bin/bash
set -e

# Install project dependencies
pnpm install

# Copy SQLite config
cp .github/workflows/test/sqlite.ormconfig.json ormconfig.json

# Compile TypeScript if build/ directory doesn't exist
if [ ! -d "build" ]; then
  echo "Build directory not found. Compiling TypeScript..."
  pnpm exec tsc
fi

# Run tests with c8 coverage
pnpm exec c8 pnpm run test:ci

echo "Tests completed successfully!"