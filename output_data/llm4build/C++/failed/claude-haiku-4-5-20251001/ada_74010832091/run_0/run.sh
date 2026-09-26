#!/bin/bash

set -e

# Clone the repository (assuming it's passed as an argument or we're already in the repo)
# If running in Docker, the repo should be mounted or copied
if [ ! -f "CMakeLists.txt" ]; then
  echo "Error: CMakeLists.txt not found. Ensure the repository is mounted or copied."
  exit 1
fi

# Set compiler
export CXX=g++-12

# Configure the build
echo "Configuring CMake..."
CMAKE_ARGS="-G \"Ninja\" -B build"
CMAKE_ARGS="$CMAKE_ARGS -DADA_TESTING=ON"
CMAKE_ARGS="$CMAKE_ARGS -DADA_BENCHMARKS=ON"
CMAKE_ARGS="$CMAKE_ARGS -DBUILD_SHARED_LIBS=ON"
CMAKE_ARGS="$CMAKE_ARGS -DADA_USE_SIMDUTF=ON"
CMAKE_ARGS="$CMAKE_ARGS -DCMAKE_BUILD_TYPE=Release"

eval cmake $CMAKE_ARGS

# Build the project
echo "Building project..."
cmake --build build -j=4

# Run tests
echo "Running tests..."
ctest --output-on-failure --test-dir build

# Run benchmarks
echo "Running benchmarks..."
cd build && benchmarks/bench

echo "Build and test completed successfully!"