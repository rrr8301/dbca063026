#!/bin/bash

# Clone the repository (simulating actions/checkout)
# Assuming the repository is already copied in the Dockerfile

# Configure CMake
cmake -S "/app" -B "/app/build" -DCMAKE_BUILD_TYPE=$BUILD_TYPE -DCMAKE_CXX_COMPILER=clang++

# Build with CMake
cmake --build "/app/build" --config $BUILD_TYPE

# Run tests with CTest
cd /app/build/test
ctest -C $BUILD_TYPE --output-on-failure