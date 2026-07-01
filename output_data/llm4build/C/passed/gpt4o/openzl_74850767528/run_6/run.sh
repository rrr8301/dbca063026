#!/bin/bash

# Configure CMake
cmake -E make_directory build
cd build

CMAKE_ARGS="-DCMAKE_INSTALL_PREFIX=./install"

if [ "dev" != "" ]; then
  CMAKE_ARGS="$CMAKE_ARGS -DOPENZL_BUILD_MODE=dev"
fi

if [ "-Werror" != "" ]; then
  CMAKE_ARGS="$CMAKE_ARGS -DZSTRONG_COMMON_FLAGS=\"-Werror\""
fi

CMAKE_ARGS="$CMAKE_ARGS -DOPENZL_BUILD_TESTS=ON"

if [ "CMake Linux" = "CMake Linux" ]; then
  CMAKE_ARGS="$CMAKE_ARGS -DOPENZL_BUILD_BENCHMARKS=ON"
fi

# Ensure Python3 is found
CMAKE_ARGS="$CMAKE_ARGS -DPython3_EXECUTABLE=$(which python3)"

echo "Running: cmake $CMAKE_ARGS .."
cmake $CMAKE_ARGS ..

# Check if cmake configuration was successful
if [ $? -ne 0 ]; then
  echo "CMake configuration failed"
  exit 1
fi

# Build
make -j2

# Check if make was successful
if [ $? -ne 0 ]; then
  echo "Make failed"
  exit 1
fi

# Build unitBench
cmake --build . --parallel --target unitBench

# Test
ctest --output-on-failure

# Install
make install