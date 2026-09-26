#!/bin/bash

# Set environment variables
export CC=gcc  # Ensure the C compiler is set
export CXX=g++-14
export CTEST_OUTPUT_ON_FAILURE=1

# Create build directory if it doesn't exist
mkdir -p build
cd build

# Compile tests
cmake -DENTT_BUILD_TESTING=ON -DENTT_BUILD_LIB=ON -DENTT_BUILD_EXAMPLE=ON -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++-14 ..
make -j4

# Run tests
ctest -C Debug -j4