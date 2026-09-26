#!/bin/bash

set -e

# Create build directory
mkdir -p build.wolf
cd build.wolf

# Configure with CMake
cmake -G Ninja \
  -DCMAKE_BUILD_TYPE=Debug \
  -DNNG_ENABLE_TLS=ON \
  -DNNG_POLLQ_POLLER=poll \
  -DNNG_TLS_ENGINE=wolf \
  ..

# Build with Ninja
ninja

# Run tests with CTest
ctest --output-on-failure