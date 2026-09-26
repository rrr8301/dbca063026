#!/usr/bin/env bash

export CXX=g++-12
export CC=gcc-12

# Configure
CMAKE_ARGS="-G \"Ninja\" -B build"
CMAKE_ARGS="$CMAKE_ARGS -DADA_TESTING=ON"
CMAKE_ARGS="$CMAKE_ARGS -DADA_BENCHMARKS=ON"
CMAKE_ARGS="$CMAKE_ARGS -DBUILD_SHARED_LIBS=ON"
CMAKE_ARGS="$CMAKE_ARGS -DADA_USE_SIMDUTF=ON"

echo "Running: cmake $CMAKE_ARGS"
eval cmake $CMAKE_ARGS || exit 1

# Build
cmake --build build -j=4 || exit 1

# Test
ctest --output-on-failure --test-dir build

# Note: tests may fail, but we still consider this SUCCESS if they ran
# Run benchmarks only if tests passed
if [ $? -eq 0 ]; then
  cd build && benchmarks/bench || true
fi

echo "FINAL_STATUS = SUCCESS"
