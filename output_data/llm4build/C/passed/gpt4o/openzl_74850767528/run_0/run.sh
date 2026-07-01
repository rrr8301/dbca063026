#!/bin/bash

# Clone the repository (assuming the repo URL is known)
# git clone <repository-url> .

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

echo "Running: cmake $CMAKE_ARGS .."
cmake $CMAKE_ARGS ..

# Build
make -j2

# Build unitBench
cmake --build . --parallel --target unitBench

# Test
ctest --output-on-failure

# Install
make install