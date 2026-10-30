#!/usr/bin/env bash

set -e

echo "=== Running Mongoose Tests ==="
echo "Node version: $(node --version)"
echo "npm version: $(npm --version)"

# Run tests
npm run test:ci

# If we get here, tests ran successfully
echo ""
echo "=== Test Run Complete ==="
echo "FINAL_STATUS = SUCCESS"
