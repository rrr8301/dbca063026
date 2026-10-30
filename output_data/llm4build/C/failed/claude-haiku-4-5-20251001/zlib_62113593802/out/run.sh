#!/bin/bash

set -e

# Navigate to workspace
cd /workspace

# Generate project files
echo "Generating project files with CMake..."
cmake -S . -B ../build \
  -DZLIB_BUILD_SHARED=OFF \
  -DMINIZIP_ENABLE_BZIP2=ON \
  -DCMAKE_BUILD_TYPE=Release \
  -DZLIB_BUILD_MINIZIP=ON

# Set compiler environment variables
export CC=gcc
export CFLAGS="-Wall -Wextra"

# Compile source code
echo "Compiling source code..."
cmake --build ../build --config Release

# Run test cases
echo "Running test cases..."
cd ../build
ctest -C Release --output-on-failure --max-width 120 || TEST_FAILED=1

# Create packages
echo "Creating packages..."
cmake --build ../build --config Release -t package package_source

# Exit with failure if tests failed
if [ "${TEST_FAILED}" = "1" ]; then
  echo "Test cases failed!"
  exit 1
fi

echo "Build and tests completed successfully!"
exit 0