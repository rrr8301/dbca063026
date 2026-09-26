#!/bin/bash

# Set build type
BUILD_TYPE=${BUILD_TYPE:-Release}

# Configure CMake
cmake -S /app -B /app/build -DCMAKE_BUILD_TYPE=$BUILD_TYPE -DCMAKE_CXX_COMPILER=g++-9

# Build with CMake
cmake --build /app/build --config $BUILD_TYPE

# Run tests
cd /app/build/test
ctest -C $BUILD_TYPE --output-on-failure