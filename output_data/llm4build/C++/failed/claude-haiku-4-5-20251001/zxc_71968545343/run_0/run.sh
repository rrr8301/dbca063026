#!/bin/bash
set -e

# Set compiler environment variables
export CC=gcc-14
export CXX=g++-14

# Verify compiler versions
gcc-14 --version
g++-14 --version

# Configure CMake
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DZXC_NATIVE_ARCH=OFF

# Build
cmake --build build --config Release --parallel

# Test (native)
cd build
ctest -C Release --output-on-failure