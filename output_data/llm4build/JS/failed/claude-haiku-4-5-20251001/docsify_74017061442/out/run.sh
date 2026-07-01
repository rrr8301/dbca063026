#!/bin/bash
set -e

# Working directory is already /workspace

# Install dependencies
echo "Installing dependencies..."
npm ci --ignore-scripts

# Build the project
echo "Building project..."
npm run build

# Run unit tests
echo "Running unit tests..."
npm run test:unit -- --ci --runInBand || UNIT_TEST_FAILED=1

# Run integration tests
echo "Running integration tests..."
npm run test:integration -- --ci --runInBand || INTEGRATION_TEST_FAILED=1

# Exit with failure if any test suite failed
if [ "$UNIT_TEST_FAILED" = "1" ] || [ "$INTEGRATION_TEST_FAILED" = "1" ]; then
    echo "One or more test suites failed."
    exit 1
fi

echo "All tests passed!"
exit 0