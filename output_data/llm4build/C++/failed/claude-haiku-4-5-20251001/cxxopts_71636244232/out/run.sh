#!/bin/bash

set -e

# Navigate to workspace
cd /workspace

# Configure CMake
cmake -S "/workspace" -B "/workspace/build" -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=g++

# Build
cmake --build "/workspace/build" --config Release

# Test
cd /workspace/build/test
ctest -C Release --output-on-failure