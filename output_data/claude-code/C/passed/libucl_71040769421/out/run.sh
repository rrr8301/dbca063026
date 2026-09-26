#!/usr/bin/env bash
set -e

BUILD_DIR="/app/build"

echo "=== Configuring CMake ==="
cmake -B "$BUILD_DIR" \
    -DCMAKE_CXX_COMPILER=g++ \
    -DCMAKE_C_COMPILER=gcc \
    -DCMAKE_BUILD_TYPE=Release \
    -S /app

echo "=== Building ==="
cmake --build "$BUILD_DIR" --config Release

echo "=== Testing ==="
cd "$BUILD_DIR"
ctest --progress --output-on-failure --build-config Release

echo "FINAL_STATUS = SUCCESS"
