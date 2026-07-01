#!/usr/bin/env bash
set -e

cd /app

# Copy sqlite config
cp .github/workflows/test/sqlite.ormconfig.json ormconfig.json

# Run tests with coverage
pnpm exec c8 pnpm run test:ci

# If tests ran successfully
echo "FINAL_STATUS = SUCCESS"
