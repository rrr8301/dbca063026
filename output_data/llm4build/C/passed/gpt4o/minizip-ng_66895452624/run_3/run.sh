#!/bin/bash

# Activate environment variables
export CC=clang
export CXX=clang++

# Generate project files
cmake -S . -B build \
  -D MZ_BUILD_TESTS=ON \
  -D MZ_BUILD_UNIT_TESTS=ON \
  -D BUILD_SHARED_LIBS=OFF \
  -D CMAKE_BUILD_TYPE=Release

# Compile source code
cmake --build build --config Release

# Run test cases
ctest --output-on-failure -C Release --test-dir build || true

# Note: Packaging and uploading release steps are skipped