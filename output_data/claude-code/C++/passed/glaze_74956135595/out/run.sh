#!/usr/bin/env bash
set -e

WORKSPACE=/app

# Prepare build directory
cmake -E make_directory "$WORKSPACE/build"

# Configure CMake
CXXFLAGS="-g3" cmake -S "$WORKSPACE" -B "$WORKSPACE/build" \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_CXX_STANDARD=23

# Build
cmake --build "$WORKSPACE/build" -j $(nproc)

# Test
ctest --output-on-failure --test-dir "$WORKSPACE/build"

echo "FINAL_STATUS = SUCCESS"
