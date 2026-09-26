#!/usr/bin/env bash
set -e

# Set compiler
export CXX=g++-9

# Create build directory
mkdir -p /tmp/build
cd /tmp/build

# Configure CMake
cmake /app \
    -DCMAKE_BUILD_TYPE=Debug \
    -DCPPSORT_BUILD_TESTING=ON \
    -DCPPSORT_SANITIZE=address,undefined \
    -DCPPSORT_BUILD_EXAMPLES=ON \
    -G"Unix Makefiles"

# Build the test suite
export ASAN_OPTIONS="use_sigaltstack=false"
export UBSAN_OPTIONS="use_sigaltstack=false"
cmake --build . --config Debug -j 2

# Run the test suite
export CTEST_OUTPUT_ON_FAILURE=1
export ASAN_OPTIONS="use_sigaltstack=false"
export UBSAN_OPTIONS="use_sigaltstack=false"
ctest -C Debug --no-tests=error

echo "FINAL_STATUS = SUCCESS"
