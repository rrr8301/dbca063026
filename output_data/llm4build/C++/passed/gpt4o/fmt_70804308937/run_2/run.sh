#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# Create build directory
mkdir -p build
cd build

# Configure the build
CXX=clang++-11 cmake -DCMAKE_BUILD_TYPE=Release \
                     -DCMAKE_CXX_STANDARD=11 \
                     -DCMAKE_CXX_VISIBILITY_PRESET=hidden \
                     -DCMAKE_VISIBILITY_INLINES_HIDDEN=ON \
                     -DFMT_DOC=OFF -DFMT_PEDANTIC=ON \
                     -DFMT_WERROR=ON \
                     ..

# Build the project
threads=$(nproc)
cmake --build . --config Release --parallel $threads

# Run tests
CTEST_OUTPUT_ON_FAILURE=True ctest -C Release