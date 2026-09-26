#!/bin/bash

# Set environment variables
export CC=gcc
export CXX=g++
export CFLAGS="-msse2"

# Configure and build with CMake
cmake -DENABLE_PNG=1 -DENABLE_FREETYPE=1 -DENABLE_JPEG=1 -DENABLE_WEBP=1 \
      -DENABLE_TIFF=1 -DENABLE_XPM=1 -DENABLE_GD_FORMATS=1 -DENABLE_HEIF=1 \
      -DENABLE_RAQM=1 -DENABLE_AVIF=1 -DBUILD_TEST=1 -B /workspace/build \
      -DCMAKE_BUILD_TYPE=RELWITHDEBINFO

cmake --build /workspace/build --config RELWITHDEBINFO --parallel 4

# Run tests
cd /workspace/build
CTEST_OUTPUT_ON_FAILURE=1 ctest -C RELWITHDEBINFO