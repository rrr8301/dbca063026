#!/bin/bash

# Install project dependencies
pnpm install

# Copy configuration file
cp .github/workflows/test/sqlite.ormconfig.json ormconfig.json

# Run tests
pnpm exec c8 pnpm run test:ci