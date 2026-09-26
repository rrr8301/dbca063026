#!/usr/bin/env bash
set -e

cd /app

# Create build directory
mkdir -p build
cd build

# Compile tests
export CXX=g++-14
cmake -DENTT_BUILD_TESTING=ON -DENTT_BUILD_LIB=ON -DENTT_BUILD_EXAMPLE=ON ..
make -j4

# Run tests
export CTEST_OUTPUT_ON_FAILURE=1
ctest -C Debug -j4

echo "FINAL_STATUS = SUCCESS"
