#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Configure CMake
cmake -E make_directory /workspace/build
cd /workspace/build

CMAKE_ARGS="-DCMAKE_INSTALL_PREFIX=./install"
CMAKE_ARGS="$CMAKE_ARGS -DOPENZL_BUILD_TESTS=ON"
CMAKE_ARGS="$CMAKE_ARGS -DOPENZL_BUILD_SHARED_LIBS=ON"
CMAKE_ARGS="$CMAKE_ARGS -DZSTRONG_COMMON_FLAGS=\"-Werror\""

echo "Running: cmake $CMAKE_ARGS .."
cmake $CMAKE_ARGS ..

# Build with increased timeout for network operations
make -j2

# Test
ctest --output-on-failure