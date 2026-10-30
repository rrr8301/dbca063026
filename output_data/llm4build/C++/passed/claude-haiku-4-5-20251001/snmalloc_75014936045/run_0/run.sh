#!/bin/bash

set -e

# Navigate to workspace
cd /workspace

# Configure CMake
cmake \
  -B /workspace/build \
  -DCMAKE_BUILD_TYPE=Debug \
  -G Ninja \
  -DSNMALLOC_CI_BUILD=ON

# Build with Ninja
cd /workspace/build
export NINJA_STATUS="%p [%f:%s/%t] %o/s, %es"
ninja

# Check binary size
ls -lh

# Run tests
ctest -j 2 --output-on-failure