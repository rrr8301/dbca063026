#!/bin/bash

set -e

# Verify CMakeLists.txt exists in workspace
if [ ! -f "/workspace/CMakeLists.txt" ]; then
    echo "Error: CMakeLists.txt not found at /workspace"
    echo "Please ensure your repository is mounted with: docker run -v /path/to/repo:/workspace ..."
    echo "Current /workspace contents:"
    ls -la /workspace || echo "(directory is empty)"
    exit 1
fi

cd /workspace

# Set reusable strings (simulating GitHub Actions step outputs)
BUILD_OUTPUT_DIR="/workspace/build"

# Configure CMake
echo "Configuring CMake..."
cmake -B "$BUILD_OUTPUT_DIR" \
    -DCMAKE_CXX_COMPILER=g++ \
    -DCMAKE_C_COMPILER=gcc \
    -DCMAKE_BUILD_TYPE=Release \
    -S /workspace

# Build
echo "Building project..."
cmake --build "$BUILD_OUTPUT_DIR" --config Release

# Test
echo "Running tests..."
cd "$BUILD_OUTPUT_DIR"
ctest --progress --output-on-failure --build-config Release

echo "All tests completed successfully!"