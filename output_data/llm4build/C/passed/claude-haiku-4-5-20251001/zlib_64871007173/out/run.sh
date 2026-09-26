#!/bin/bash

set -e

# Use existing repository (assume code is already present in /workspace)
if [ ! -d "/workspace/zlib" ] && [ ! -f "/workspace/CMakeLists.txt" ]; then
    echo "Cloning repository..."
    git clone https://github.com/madler/zlib.git /workspace/zlib
    cd /workspace/zlib
else
    cd /workspace
fi

# Set compiler environment variables
export CC=gcc
export CFLAGS="-Wall -Wextra"

# Generate project files with CMake
echo "Generating project files with CMake..."
cmake -S . -B ../build \
    -DMINIZIP_ENABLE_BZIP2=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DZLIB_BUILD_MINIZIP=ON

# Compile source code
echo "Compiling source code..."
cmake --build ../build --config Release

# Run test cases
echo "Running test cases..."
cd ../build
ctest -C Release --output-on-failure --max-width 120 || TEST_FAILED=1

# Create packages
echo "Creating packages..."
cmake --build ../build --config Release -t package package_source || PACKAGE_FAILED=1

# Report results
echo "Build and test process completed."
if [ "$TEST_FAILED" = "1" ]; then
    echo "WARNING: Some tests failed."
    exit 1
fi
if [ "$PACKAGE_FAILED" = "1" ]; then
    echo "WARNING: Package creation failed."
    exit 1
fi

exit 0