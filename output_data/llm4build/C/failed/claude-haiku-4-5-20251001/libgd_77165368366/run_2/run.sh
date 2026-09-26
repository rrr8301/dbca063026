#!/bin/bash
set -e

# Set environment variables for the build
export CC=gcc
export CXX=g++
export CFLAGS="-msse2"
export BUILD_TYPE=RELWITHDEBINFO
export TMP=/tmp
export LSAN_OPTIONS="suppressions=/workspace/suppressions/lsan.supp"
export CTEST_OUTPUT_ON_FAILURE=1

# Create build directory
mkdir -p /workspace/build

# Configure CMake
echo "Configuring CMake..."
cmake \
  -DENABLE_PNG=1 \
  -DENABLE_FREETYPE=1 \
  -DENABLE_JPEG=1 \
  -DENABLE_WEBP=1 \
  -DENABLE_TIFF=1 \
  -DENABLE_XPM=1 \
  -DENABLE_GD_FORMATS=1 \
  -DENABLE_HEIF=1 \
  -DENABLE_RAQM=1 \
  -DENABLE_AVIF=1 \
  -DBUILD_TEST=1 \
  -B /workspace/build \
  -S /workspace \
  -DCMAKE_BUILD_TYPE=${BUILD_TYPE}

# Build
echo "Building..."
cmake --build /workspace/build --config ${BUILD_TYPE} --parallel 4

# Run tests
echo "Running tests..."
cd /workspace/build
ctest -C ${BUILD_TYPE}

echo "Build and test completed."