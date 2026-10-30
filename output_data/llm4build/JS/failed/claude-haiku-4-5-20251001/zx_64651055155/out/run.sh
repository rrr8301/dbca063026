#!/bin/bash

set -e

# Enable error handling: continue on test failures but track exit code
test_failed=0

echo "=========================================="
echo "Installing dependencies with npm ci..."
echo "=========================================="
npm ci || { echo "npm ci failed"; test_failed=1; }

echo ""
echo "=========================================="
echo "Running unit tests with coverage..."
echo "=========================================="
npm run test:coverage || { echo "Unit tests failed"; test_failed=1; }

echo ""
echo "=========================================="
echo "Running type tests..."
echo "=========================================="
npm run test:types || { echo "Type tests failed"; test_failed=1; }

echo ""
echo "=========================================="
echo "Test execution completed"
echo "=========================================="

if [ $test_failed -ne 0 ]; then
    echo "Some tests failed. See output above for details."
    exit 1
fi

exit 0