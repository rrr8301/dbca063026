#!/bin/bash

set -e

# Verify repository exists (should be mounted or checked out)
if [ ! -d "/workspace" ] || [ -z "$(ls -A /workspace)" ]; then
    echo "Error: Repository not found at /workspace"
    echo "Please mount your repository with: docker run -v /path/to/repo:/workspace ..."
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