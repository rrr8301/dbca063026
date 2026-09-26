#!/bin/bash

set -e

# Set build type
export BUILD_TYPE=Release

# Configure
cmake -B/workspace/build \
  -DBUILD_SHARED_LIBS=ON -DVISIBILITY_HIDDEN=ON \
  -DBUILD_TESTING=ON -DBUILD_EXAMPLES=ON -DBUILD_BINDINGS=ON \
  -DCMAKE_BUILD_TYPE=$BUILD_TYPE

# Build
cmake --build /workspace/build --config $BUILD_TYPE --parallel

# Test
cd /workspace/build
ctest -C $BUILD_TYPE -V --no-tests=error