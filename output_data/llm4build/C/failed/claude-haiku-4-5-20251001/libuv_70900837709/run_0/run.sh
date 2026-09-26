#!/bin/bash
set -e

# Configure CMake build
cmake -B build -DBUILD_TESTING=ON

# Build the project
cmake --build build

# Run tests
cd build && ctest -V --output-on-failure