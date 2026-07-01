#!/bin/bash

# Install project dependencies
pnpm install

# Check if the build script exists in package.json
if ! pnpm run | grep -q "build"; then
  echo "No build script found in package.json. Please define a build script."
  exit 1
fi

# Build the project to compile TypeScript files
pnpm run build

# Ensure the test files are correctly specified
if [ ! -f ".github/workflows/test/sqlite.ormconfig.json" ]; then
  echo "Configuration file not found. Please ensure the path is correct."
  exit 1
fi

# Copy configuration file
cp .github/workflows/test/sqlite.ormconfig.json ormconfig.json

# Run tests
pnpm exec c8 pnpm run test:ci