#!/bin/bash
set -e

# Install project dependencies
echo "Installing dependencies..."
pnpm install --frozen-lockfile

# Run tests
echo "Running Global tests..."
pnpm test:global || TEST_GLOBAL_FAILED=1

echo "Running Service tests..."
pnpm test:service || TEST_SERVICE_FAILED=1

echo "Running App tests..."
pnpm test:app || TEST_APP_FAILED=1

# Report results
if [ -n "$TEST_GLOBAL_FAILED" ] || [ -n "$TEST_SERVICE_FAILED" ] || [ -n "$TEST_APP_FAILED" ]; then
    echo "Some tests failed"
    exit 1
fi

echo "All tests passed!"
exit 0