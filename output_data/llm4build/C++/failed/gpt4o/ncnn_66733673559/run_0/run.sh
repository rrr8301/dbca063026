#!/bin/bash

# Set environment variables for clang
export CC=clang
export CXX=clang++

# Build the project
mkdir build-sse2 && cd build-sse2
cmake -DNCNN_AVX=OFF -DNCNN_AVX2=OFF -DNCNN_BUILD_TESTS=ON ..
cmake --build . -j $(nproc)

# Run tests
ctest --output-on-failure -j $(nproc)