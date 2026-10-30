#!/bin/bash
set -e

# Set compiler environment variable
export CXX=g++-14

# Create build directory
mkdir -p build
cd build

# Compile tests
echo "=== Compiling tests ==="
cmake -DENTT_BUILD_TESTING=ON -DENTT_BUILD_LIB=ON -DENTT_BUILD_EXAMPLE=ON ..
make -j4

# Run tests
echo "=== Running tests ==="
export CTEST_OUTPUT_ON_FAILURE=1
ctest -C Debug -j4

echo "=== All tests completed ==="