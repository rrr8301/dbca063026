#!/bin/bash

# Set environment variables
export CXX=clang++-14
export CXXFLAGS="-fsanitize=address,undefined -fno-sanitize-recover=all -fno-omit-frame-pointer"

# Create build directory
mkdir -p build
cd build

# Configure the project
cmake -DCMAKE_BUILD_TYPE=Debug \
      -DCMAKE_CXX_STANDARD=20 \
      -DCMAKE_CXX_COMPILER=clang++-14 \  # Ensure the correct compiler is set
      -DCMAKE_CXX_VISIBILITY_PRESET=hidden \
      -DCMAKE_VISIBILITY_INLINES_HIDDEN=ON \
      -DFMT_DOC=OFF -DFMT_PEDANTIC=ON -DFMT_WERROR=ON \
      ..

# Build the project
threads=$(nproc)
cmake --build . --config Debug --parallel $threads

# Run tests
CTEST_OUTPUT_ON_FAILURE=True ctest -C Debug