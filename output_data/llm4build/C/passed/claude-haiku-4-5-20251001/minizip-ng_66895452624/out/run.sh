#!/bin/bash

set -e

# Set compiler environment variables
export CC=clang
export CXX=clang++

echo "=========================================="
echo "Building minizip-ng with Clang"
echo "=========================================="

# Generate project files
echo "Generating project files with CMake..."
cmake -S . -B . \
  -D MZ_BUILD_TESTS=ON \
  -D MZ_BUILD_UNIT_TESTS=ON \
  -D BUILD_SHARED_LIBS=OFF \
  -D CMAKE_BUILD_TYPE=Release

# Compile source code
echo "Compiling source code..."
cmake --build . --config Release

# Run test cases
echo "Running test cases..."
ctest --output-on-failure -C Release

echo "=========================================="
echo "Build and tests completed successfully!"
echo "=========================================="