#!/bin/bash

set -e

# Track test failures
TEST_FAILED=0
STYLE_FAILED=0

echo "=========================================="
echo "Running npm tests..."
echo "=========================================="
if npm run test; then
    echo "✓ Tests passed"
else
    echo "✗ Tests failed"
    TEST_FAILED=1
fi

echo ""
echo "=========================================="
echo "Running code style check..."
echo "=========================================="
if npm run check-style; then
    echo "✓ Code style check passed"
else
    echo "✗ Code style check failed"
    STYLE_FAILED=1
fi

echo ""
echo "=========================================="
echo "Test Summary"
echo "=========================================="
if [ $TEST_FAILED -eq 0 ] && [ $STYLE_FAILED -eq 0 ]; then
    echo "✓ All checks passed"
    exit 0
else
    if [ $TEST_FAILED -eq 1 ]; then
        echo "✗ Tests failed"
    fi
    if [ $STYLE_FAILED -eq 1 ]; then
        echo "✗ Code style check failed"
    fi
    exit 1
fi