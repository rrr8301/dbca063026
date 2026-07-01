#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Prepare build directory
cmake -E make_directory "/workspace/build"

# Configure CMake
CXXFLAGS="-g3" cmake -S "/workspace" -B "/workspace/build" -DCMAKE_BUILD_TYPE=Debug -DCMAKE_CXX_STANDARD=23

# Build
cmake --build "/workspace/build" -j $(nproc)

# Test
ctest --output-on-failure --test-dir "/workspace/build"