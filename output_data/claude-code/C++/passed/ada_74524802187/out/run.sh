#!/usr/bin/env bash

set -e

export CXX=g++-12
export CC=gcc-12

# Configure
CMAKE_ARGS="-G \"Ninja\" -B build"
CMAKE_ARGS="$CMAKE_ARGS -DADA_TESTING=ON"
CMAKE_ARGS="$CMAKE_ARGS -DADA_BENCHMARKS=ON"
CMAKE_ARGS="$CMAKE_ARGS -DBUILD_SHARED_LIBS=ON"
CMAKE_ARGS="$CMAKE_ARGS -DADA_USE_SIMDUTF=ON"

echo "Running: cmake $CMAKE_ARGS"
eval cmake $CMAKE_ARGS

# Build
cmake --build build -j=4

# Test
ctest --output-on-failure --test-dir build

# Run benchmarks
cd build && benchmarks/bench

echo "FINAL_STATUS = SUCCESS"
