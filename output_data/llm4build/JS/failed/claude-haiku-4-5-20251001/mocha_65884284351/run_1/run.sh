#!/bin/bash

set -e

# Enable error handling: continue on test failures but track exit code
TEST_EXIT_CODE=0

echo "=========================================="
echo "Node.js Test Environment Setup"
echo "=========================================="

# Display versions
echo "Node.js version:"
node --version
echo "npm version:"
npm --version
echo "Git version:"
git --version

echo ""
echo "=========================================="
echo "Installing Project Dependencies"
echo "=========================================="

# Install dependencies without running scripts (as per workflow)
npm ci --ignore-scripts || { TEST_EXIT_CODE=$?; echo "npm ci failed with exit code $TEST_EXIT_CODE"; }

echo ""
echo "=========================================="
echo "Running Integration Tests"
echo "=========================================="

# Set environment variables as per workflow
export BROWSER=""
export COVERAGE=""
export NODE_OPTIONS="--trace-warnings"

# Run the integration test script
# Continue on failure to allow other tests to run
npm run test-node:integration || { TEST_EXIT_CODE=$?; echo "test-node:integration failed with exit code $TEST_EXIT_CODE"; }

echo ""
echo "=========================================="
echo "Test Execution Complete"
echo "=========================================="

# Exit with the test exit code
exit $TEST_EXIT_CODE