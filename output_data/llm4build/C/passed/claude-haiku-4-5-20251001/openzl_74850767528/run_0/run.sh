#!/bin/bash
set -e

# Set environment variables
export MAKEFLAGS="V=1"

# Check CMake version
echo "Checking CMake version..."
cmake --version

# Configure CMake
echo "Configuring CMake..."
mkdir -p /workspace/build
cd /workspace/build

CMAKE_ARGS="-DCMAKE_INSTALL_PREFIX=./install"
CMAKE_ARGS="$CMAKE_ARGS -DOPENZL_BUILD_MODE=dev"
CMAKE_ARGS="$CMAKE_ARGS -DZSTRONG_COMMON_FLAGS=\"-Werror\""
CMAKE_ARGS="$CMAKE_ARGS -DOPENZL_BUILD_TESTS=ON"
CMAKE_ARGS="$CMAKE_ARGS -DOPENZL_BUILD_BENCHMARKS=ON"

echo "Running: cmake $CMAKE_ARGS .."
cmake $CMAKE_ARGS ..

# Build
echo "Building..."
make -j2

# Build unitBench
echo "Building unitBench..."
cmake --build . --parallel --target unitBench

# Run tests
echo "Running tests..."
ctest --output-on-failure

# Install
echo "Installing..."
make install

echo "All steps completed successfully!"