#!/usr/bin/env bash
set -e

# Create build directory
mkdir -p build
cd build

# Configure CMake
CMAKE_ARGS="-DCMAKE_INSTALL_PREFIX=./install"
CMAKE_ARGS="$CMAKE_ARGS -DOPENZL_BUILD_MODE=dev"
CMAKE_ARGS="$CMAKE_ARGS -DZSTRONG_COMMON_FLAGS=\"-Werror\""
CMAKE_ARGS="$CMAKE_ARGS -DOPENZL_BUILD_TESTS=ON"
CMAKE_ARGS="$CMAKE_ARGS -DOPENZL_BUILD_BENCHMARKS=ON"

echo "Running: cmake $CMAKE_ARGS .."
cmake $CMAKE_ARGS ..

# Build
make -j2

# Build unitBench
cmake --build . --parallel --target unitBench

# Test
ctest --output-on-failure || true

# Install
make install

echo "FINAL_STATUS = SUCCESS"
