#!/bin/bash

set -e

# Enable error handling: continue on test failures but track exit code
TEST_EXIT_CODE=0

echo "=========================================="
echo "Node.js and npm versions:"
echo "=========================================="
node --version
npm --version

echo ""
echo "=========================================="
echo "Installing dependencies with npm ci..."
echo "=========================================="
npm ci --ignore-scripts || { TEST_EXIT_CODE=$?; echo "npm ci failed with exit code $TEST_EXIT_CODE"; }

echo ""
echo "=========================================="
echo "Running unit tests..."
echo "=========================================="
npm run test-node:unit || { TEST_EXIT_CODE=$?; echo "test-node:unit failed with exit code $TEST_EXIT_CODE"; }

echo ""
echo "=========================================="
echo "Generating coverage report..."
echo "=========================================="
npm run test-coverage-generate || { TEST_EXIT_CODE=$?; echo "test-coverage-generate failed with exit code $TEST_EXIT_CODE"; }

echo ""
echo "=========================================="
echo "Test execution completed"
echo "=========================================="

exit $TEST_EXIT_CODE