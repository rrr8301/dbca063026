#!/bin/bash

set -e

# Track test results
TESTS_FAILED=0
TESTS_PASSED=0
BUILD_FAILED=0

echo "=========================================="
echo "Building C++ libphonenumber"
echo "=========================================="

# Navigate to cpp directory and build
cd /workspace/cpp
mkdir -p build
cd build

echo "Running CMake..."
if ! cmake .. -DCMAKE_BUILD_TYPE=Release; then
    echo "✗ CMake configuration FAILED"
    BUILD_FAILED=1
fi

echo "Running Make..."
if ! make -j$(nproc); then
    echo "✗ Make build FAILED"
    BUILD_FAILED=1
fi

if [ $BUILD_FAILED -eq 1 ]; then
    echo ""
    echo "=========================================="
    echo "Build Failed"
    echo "=========================================="
    exit 1
fi

echo ""
echo "=========================================="
echo "Running C++ Tests"
echo "=========================================="

# Test 1: Build Tools Test
echo ""
echo "Test 1: Running generate_geocoding_data_test..."
if [ -f ./tools/generate_geocoding_data_test ]; then
    if ./tools/generate_geocoding_data_test; then
        echo "✓ generate_geocoding_data_test PASSED"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "✗ generate_geocoding_data_test FAILED"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
else
    echo "⊘ generate_geocoding_data_test not found, skipping..."
fi

# Test 2: API Test
echo ""
echo "Test 2: Running libphonenumber_test..."
if [ -f ./libphonenumber_test ]; then
    if ./libphonenumber_test; then
        echo "✓ libphonenumber_test PASSED"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "✗ libphonenumber_test FAILED"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
else
    echo "✗ libphonenumber_test not found"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

echo ""
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo "Test Suites Passed: $TESTS_PASSED"
echo "Test Suites Failed: $TESTS_FAILED"

if [ $TESTS_FAILED -eq 0 ]; then
    echo "All test suites passed!"
    exit 0
else
    echo "$TESTS_FAILED test suite(s) failed"
    exit 1
fi