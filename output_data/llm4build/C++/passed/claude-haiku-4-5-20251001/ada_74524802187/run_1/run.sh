#!/bin/bash
set -e

# Source Rust environment
. $HOME/.cargo/env

# Set compiler
export CXX=g++-12

# Configure the build
CMAKE_ARGS="-G \"Ninja\" -B build"
CMAKE_ARGS="$CMAKE_ARGS -DADA_TESTING=ON"
CMAKE_ARGS="$CMAKE_ARGS -DADA_BENCHMARKS=ON"
CMAKE_ARGS="$CMAKE_ARGS -DBUILD_SHARED_LIBS=ON"
CMAKE_ARGS="$CMAKE_ARGS -DADA_USE_SIMDUTF=ON"
CMAKE_ARGS="$CMAKE_ARGS -DCMAKE_BUILD_TYPE=Release"

echo "Running: cmake $CMAKE_ARGS"
eval cmake $CMAKE_ARGS

# Build
BUILD_ARGS="--build build -j=4"
echo "Running: cmake $BUILD_ARGS"
cmake $BUILD_ARGS

# Run tests
TEST_ARGS="--output-on-failure --test-dir build"
echo "Running: ctest $TEST_ARGS"
ctest $TEST_ARGS

# Run benchmarks
echo "Running benchmarks..."
cd build && benchmarks/bench