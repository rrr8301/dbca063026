#!/bin/bash

set -e

# Clone the repository (assuming it's passed as an argument or we're already in the repo)
# If running in Docker, the repo should be mounted or copied
if [ ! -f "CMakeLists.txt" ]; then
  echo "Error: CMakeLists.txt not found in $(pwd)"
  echo "Usage: docker run -v /path/to/ada:/workspace <image>"
  echo "Or: docker run -v $(pwd):/workspace <image>"
  exit 1
fi

# Set compiler
export CXX=g++-12

# Configure the build
echo "Configuring CMake..."
CMAKE_ARGS="-G Ninja -B build"
CMAKE_ARGS="$CMAKE_ARGS -DADA_TESTING=ON"
CMAKE_ARGS="$CMAKE_ARGS -DADA_BENCHMARKS=ON"
CMAKE_ARGS="$CMAKE_ARGS -DBUILD_SHARED_LIBS=ON"
CMAKE_ARGS="$CMAKE_ARGS -DADA_USE_SIMDUTF=ON"
CMAKE_ARGS="$CMAKE_ARGS -DCMAKE_BUILD_TYPE=Release"

echo "Running: cmake $CMAKE_ARGS"
cmake $CMAKE_ARGS

# Build the project
echo "Building project..."
cmake --build build -j4

# Run tests
echo "Running tests..."
ctest --output-on-failure --test-dir build

# Run benchmarks
echo "Running benchmarks..."
cd build && ./benchmarks/bench

echo "Build and test completed successfully!"