#!/bin/bash

set -e

# Set build type
BUILD_TYPE="Release"
WORKSPACE="/workspace"

# Configure
cmake -B${WORKSPACE}/build \
  -DBUILD_SHARED_LIBS=ON -DVISIBILITY_HIDDEN=ON \
  -DBUILD_TESTING=ON -DBUILD_EXAMPLES=ON -DBUILD_BINDINGS=ON \
  -DCMAKE_BUILD_TYPE=${BUILD_TYPE}

# Build
cmake --build ${WORKSPACE}/build --config ${BUILD_TYPE} --parallel

# Test
cd ${WORKSPACE}/build
ctest -C ${BUILD_TYPE} -V --no-tests=error