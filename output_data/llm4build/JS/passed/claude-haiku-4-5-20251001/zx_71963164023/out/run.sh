#!/bin/bash

set -e

# Enable error handling: continue on test failures but track exit code
test_exit_code=0

echo "=========================================="
echo "Running Unit Tests with Coverage"
echo "=========================================="
if npm run test:coverage; then
    echo "✓ Unit tests passed"
else
    echo "✗ Unit tests failed"
    test_exit_code=1
fi

echo ""
echo "=========================================="
echo "Running Type Tests"
echo "=========================================="
if npm run test:types; then
    echo "✓ Type tests passed"
else
    echo "✗ Type tests failed"
    test_exit_code=1
fi

echo ""
echo "=========================================="
echo "Test Summary"
echo "=========================================="
if [ $test_exit_code -eq 0 ]; then
    echo "✓ All tests passed"
    exit 0
else
    echo "✗ Some tests failed"
    exit $test_exit_code
fi