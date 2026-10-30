#!/bin/bash

set -e

# Track test results
TESTS_FAILED=0

echo "=========================================="
echo "Building C++ libphonenumber"
echo "=========================================="

# Navigate to cpp directory and build
cd /workspace/cpp
mkdir -p build
cd build

echo "Running CMake..."
cmake .. -DCMAKE_BUILD_TYPE=Release

echo "Running Make..."
make -j$(nproc)

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

if [ $TESTS_FAILED -eq 0 ]; then
    echo "All tests passed!"
    exit 0
else
    echo "$TESTS_FAILED test(s) failed"
    exit 1
fi