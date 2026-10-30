#!/bin/bash

set -e

# Set environment variables
export CXX=clang++-11
export CXXFLAGS=""
export CTEST_OUTPUT_ON_FAILURE=True

# Create build directory
BUILD_DIR="/workspace/build"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Configure
echo "=== Configuring CMake ==="
cmake -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_CXX_STANDARD=11 \
      -DCMAKE_CXX_VISIBILITY_PRESET=hidden \
      -DCMAKE_VISIBILITY_INLINES_HIDDEN=ON \
      -DFMT_DOC=OFF \
      -DFMT_PEDANTIC=ON \
      -DFMT_WERROR=ON \
      /workspace

# Build
echo "=== Building ==="
threads=$(nproc)
cmake --build . --config Release --parallel "$threads"

# Test
echo "=== Running Tests ==="
ctest -C Release --output-on-failure || true

echo "=== Build and Test Complete ==="