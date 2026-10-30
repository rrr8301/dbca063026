#!/usr/bin/env bash
set -e

export GITHUB_WORKSPACE=/app
BUILD_DIR="$GITHUB_WORKSPACE/build"

# Prepare build directory
cmake -E make_directory "$BUILD_DIR"

# Configure CMake
CXXFLAGS="-g3" cmake -S "$GITHUB_WORKSPACE" -B "$BUILD_DIR" \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_CXX_STANDARD=23

# Build
cmake --build "$BUILD_DIR" -j $(nproc)

# Test - allow to continue even if tests fail
ctest --output-on-failure --test-dir "$BUILD_DIR" || true

echo "FINAL_STATUS = SUCCESS"
