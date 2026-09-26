#!/usr/bin/env bash
set -e

export CC=clang
export CXX=clang++

echo "=== Generating project files ==="
cmake -S . -B . \
  -D MZ_BUILD_TESTS=ON \
  -D MZ_BUILD_UNIT_TESTS=ON \
  -D BUILD_SHARED_LIBS=OFF \
  -D CMAKE_BUILD_TYPE=Release

echo "=== Compiling source code ==="
cmake --build . --config Release

echo "=== Running test cases ==="
ctest --output-on-failure -C Release

echo ""
echo "FINAL_STATUS = SUCCESS"
