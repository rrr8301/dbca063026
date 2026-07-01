#!/bin/bash
set -e

# Install project dependencies
pnpm install

# Copy SQLite config
cp .github/workflows/test/sqlite.ormconfig.json ormconfig.json

# Build if build/ directory doesn't exist (artifact simulation)
if [ ! -d "build" ]; then
  echo "Build directory not found. Running build step..."
  pnpm run build || true
fi

# Run tests with c8 coverage
pnpm exec c8 pnpm run test:ci

echo "Tests completed successfully!"