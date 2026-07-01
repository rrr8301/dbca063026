#!/bin/bash

set -e

# Enable error handling to continue on test failures
trap 'TEST_FAILED=1' ERR

TEST_FAILED=0

echo "=========================================="
echo "Building libevent with CMake"
echo "=========================================="

# Build configuration
EVENT_CMAKE_OPTIONS=""
JOBS=20

# Create and enter build directory
mkdir -p build
cd build

# Configure with CMake
echo "[cmake]: cmake .. -DEVENT__ENABLE_GCC_WARNINGS=ON $EVENT_CMAKE_OPTIONS"
if ! cmake .. -DEVENT__ENABLE_GCC_WARNINGS=ON $EVENT_CMAKE_OPTIONS; then
    echo "Initial CMake configuration failed, cleaning and retrying..."
    rm -rf *
    cmake .. -DEVENT__ENABLE_GCC_WARNINGS=ON $EVENT_CMAKE_OPTIONS
fi

# Build
echo "=========================================="
echo "Building project"
echo "=========================================="
cmake --build .

# Run tests
echo "=========================================="
echo "Running tests"
echo "=========================================="

export CTEST_PARALLEL_LEVEL=$JOBS
export CTEST_OUTPUT_ON_FAILURE=1
export TSAN_OPTIONS=suppressions=$PWD/../extra/tsan.supp:allocator_may_return_null=1
export LSAN_OPTIONS=suppressions=$PWD/../extra/lsan.supp
export ASAN_OPTIONS=allocator_may_return_null=1

if ! cmake --build . --target verify; then
    echo "Tests failed!"
    TEST_FAILED=1
fi

echo "=========================================="
echo "Build and test complete"
echo "=========================================="

exit $TEST_FAILED