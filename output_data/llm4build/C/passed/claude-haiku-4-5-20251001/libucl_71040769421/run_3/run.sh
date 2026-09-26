#!/bin/bash

set -e

# Determine the source directory (support both GitHub Actions and local Docker)
SOURCE_DIR="${SOURCE_DIR:-.}"

# Verify CMakeLists.txt exists
if [ ! -f "$SOURCE_DIR/CMakeLists.txt" ]; then
    echo "Error: CMakeLists.txt not found at $SOURCE_DIR"
    echo "Please ensure your repository is mounted with: docker run -v /path/to/repo:/workspace ..."
    echo "Current $SOURCE_DIR contents:"
    ls -la "$SOURCE_DIR" || echo "(directory is empty)"
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
    -S "$SOURCE_DIR"

# Build
echo "Building project..."
cmake --build "$BUILD_OUTPUT_DIR" --config Release

# Test
echo "Running tests..."
cd "$BUILD_OUTPUT_DIR"
ctest --progress --output-on-failure --build-config Release

echo "All tests completed successfully!"