#!/bin/bash

# Set environment variables
export CXX=g++-12

# Configure the build
CMAKE_ARGS="-G Ninja -B build"
CMAKE_ARGS="$CMAKE_ARGS -DADA_TESTING=ON"
CMAKE_ARGS="$CMAKE_ARGS -DADA_BENCHMARKS=ON"
CMAKE_ARGS="$CMAKE_ARGS -DBUILD_SHARED_LIBS=ON"
CMAKE_ARGS="$CMAKE_ARGS -DADA_USE_SIMDUTF=ON"

echo "Running: cmake $CMAKE_ARGS"
cmake $CMAKE_ARGS

# Build the project
BUILD_ARGS="--build build -j=4"
cmake $BUILD_ARGS

# Run tests
TEST_ARGS="--output-on-failure --test-dir build"
ctest $TEST_ARGS