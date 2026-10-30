#!/bin/bash

# Clone the repository (simulating actions/checkout)
git clone https://github.com/your/repo.git /app
cd /app

# Select Latest Compiler (Linux)
export CC=gcc-14
export CXX=g++-14
gcc-14 --version

# Configure CMake
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DZXC_NATIVE_ARCH=OFF

# Build
cmake --build build --config Release --parallel

# Test (native)
cd build
ctest -C Release --output-on-failure