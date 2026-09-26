#!/bin/bash

# Prepare build directory
cmake -E make_directory "/app/build"

# Configure CMake
CXXFLAGS="-g3" cmake -S "/app" -B "/app/build" -DCMAKE_BUILD_TYPE=Debug -DCMAKE_CXX_STANDARD=23

# Build
cmake --build "/app/build" -j $(nproc)

# Test
ctest --output-on-failure --test-dir "/app/build"