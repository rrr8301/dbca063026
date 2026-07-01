#!/bin/bash
set -e

# Set compiler environment variables
export CC=clang
export CXX=clang++

# Build SSE2 variant
mkdir -p build-sse2
cd build-sse2
cmake -DNCNN_AVX=OFF -DNCNN_AVX2=OFF -DNCNN_BUILD_TESTS=ON ..
cmake --build . -j $(nproc)

# Run tests
ctest --output-on-failure -j $(nproc)