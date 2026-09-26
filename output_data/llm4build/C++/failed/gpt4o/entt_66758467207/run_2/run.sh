#!/bin/bash

# Set environment variables
export CXX=g++-14
export CTEST_OUTPUT_ON_FAILURE=1

# Create build directory if it doesn't exist
mkdir -p build
cd build

# Compile tests
cmake -DENTT_BUILD_TESTING=ON -DENTT_BUILD_LIB=ON -DENTT_BUILD_EXAMPLE=ON ..
make -j4

# Run tests
ctest -C Debug -j4