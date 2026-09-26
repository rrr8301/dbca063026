#!/usr/bin/env bash

set -e

export CC=gcc
export CXX=g++
export CFLAGS=""
export LDFLAGS=""

# Generate project files
cmake -S . -B . -D MZ_SANITIZER=Address \
  -D MZ_BUILD_TESTS=ON \
  -D MZ_BUILD_UNIT_TESTS=ON \
  -D BUILD_SHARED_LIBS=OFF \
  -D CMAKE_BUILD_TYPE=Release

# Compile source code
cmake --build . --config Release

# Run test cases
ctest --output-on-failure -C Release

echo "FINAL_STATUS = SUCCESS"
