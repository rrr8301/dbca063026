#!/bin/bash

set -e

# Enable error handling: continue on test failures but track exit status
test_failed=0

echo "=========================================="
echo "Building ccache - ubuntu-22.04-gcc-11"
echo "=========================================="

# Verify environment
echo "CC: $CC"
echo "CXX: $CXX"
echo "CMAKE_GENERATOR: $CMAKE_GENERATOR"
echo "CMAKE_PARAMS: $CMAKE_PARAMS"

# Run build script
echo ""
echo "Running build script..."
if [ -f "ci/build" ]; then
    bash ci/build || test_failed=$?
else
    echo "ERROR: ci/build script not found"
    exit 1
fi

# Collect testdir if build/tests failed
if [ $test_failed -ne 0 ]; then
    echo ""
    echo "Tests failed. Attempting to collect testdir..."
    if [ -f "ci/collect-testdir" ]; then
        bash ci/collect-testdir || true
    fi
fi

echo ""
echo "=========================================="
if [ $test_failed -eq 0 ]; then
    echo "Build and tests completed successfully"
    echo "=========================================="
    exit 0
else
    echo "Build or tests failed with exit code: $test_failed"
    echo "=========================================="
    exit $test_failed
fi