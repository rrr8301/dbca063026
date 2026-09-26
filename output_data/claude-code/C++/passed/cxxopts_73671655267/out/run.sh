#!/usr/bin/env bash

set -e

BUILD_TYPE=Release
CXX_COMPILER=g++-9

# Configure CMake
cmake -S /app -B /app/build -DCMAKE_BUILD_TYPE=$BUILD_TYPE -DCMAKE_CXX_COMPILER=$CXX_COMPILER

# Build
cmake --build /app/build --config $BUILD_TYPE

# Test
cd /app/build/test
ctest -C $BUILD_TYPE --output-on-failure

echo "FINAL_STATUS = SUCCESS"
