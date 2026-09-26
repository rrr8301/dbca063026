#!/bin/bash
set -e

# Set workspace directory
GITHUB_WORKSPACE="/workspace"

# Prepare build directory
cmake -E make_directory "$GITHUB_WORKSPACE/build"

# Configure CMake with C++23 standard and Debug build type
CXXFLAGS="-g3" cmake -S "$GITHUB_WORKSPACE" -B "$GITHUB_WORKSPACE/build" -DCMAKE_BUILD_TYPE=Debug -DCMAKE_CXX_STANDARD=23

# Build the project
cmake --build "$GITHUB_WORKSPACE/build" -j $(nproc)

# Run tests
ctest --output-on-failure --test-dir "$GITHUB_WORKSPACE/build"