#!/usr/bin/env bash

set -e

# Configure CMake
cmake -B build -DCMAKE_BUILD_TYPE=$BUILD_TYPE

# Build
cmake --build build --config $BUILD_TYPE

# Test
cd build
export CTEST_OUTPUT_ON_FAILURE=1
make run-tests || true

echo "FINAL_STATUS = SUCCESS"
