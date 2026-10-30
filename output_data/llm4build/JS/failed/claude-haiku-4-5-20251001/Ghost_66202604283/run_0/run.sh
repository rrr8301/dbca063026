#!/bin/bash

set -e

# Print environment info
echo "Node version: $(node --version)"
echo "Yarn version: $(yarn --version)"
echo "Database: $DB"
echo "Node environment: $NODE_ENV"

# Build TS packages
echo "Building TS packages..."
yarn nx run-many -t build --exclude=ghost-admin

# Run E2E tests
echo "Running E2E tests..."
cd ghost/core
yarn test:ci:e2e || TEST_E2E_FAILED=1

# Run integration tests
echo "Running integration tests..."
yarn test:ci:integration || TEST_INTEGRATION_FAILED=1

# Exit with failure if any tests failed
if [ "$TEST_E2E_FAILED" = "1" ] || [ "$TEST_INTEGRATION_FAILED" = "1" ]; then
    echo "Some tests failed!"
    exit 1
fi

echo "All tests passed!"
exit 0