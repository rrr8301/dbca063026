#!/bin/bash

set -e

# Enable error handling: continue on test failures but track exit code
TEST_FAILED=0

echo "=========================================="
echo "Fleetbench Build and Test"
echo "=========================================="

# Change to workspace directory
cd /workspace

echo ""
echo "=========================================="
echo "Step 1: Update Bazel Requirements"
echo "=========================================="
bazel run //fleetbench:requirements.update || {
    echo "Warning: requirements.update failed, continuing..."
}

echo ""
echo "=========================================="
echo "Step 2: Build with fastbuild + clang"
echo "=========================================="
bazel build -c fastbuild --config=clang //... || {
    echo "ERROR: Build failed"
    exit 1
}

echo ""
echo "=========================================="
echo "Step 3: Run Tests with fastbuild + clang"
echo "=========================================="
bazel test -c fastbuild --config=clang --test_output=errors //... || {
    echo "WARNING: Some tests failed"
    TEST_FAILED=1
}

echo ""
echo "=========================================="
echo "Build and Test Summary"
echo "=========================================="
if [ $TEST_FAILED -eq 0 ]; then
    echo "✓ All tests passed"
    exit 0
else
    echo "✗ Some tests failed (see output above)"
    exit 1
fi