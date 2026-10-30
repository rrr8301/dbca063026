#!/bin/bash

set -e

# Build and install libultrahdr
curl -L -o /tmp/libultrahdr-1.4.0.tar.gz https://github.com/google/libultrahdr/archive/refs/tags/v1.4.0.tar.gz
mkdir -p /tmp/libultrahdr-src /tmp/libultrahdr-build
tar -xzf /tmp/libultrahdr-1.4.0.tar.gz -C /tmp/libultrahdr-src --strip-components=1
cmake -S /tmp/libultrahdr-src -B /tmp/libultrahdr-build -G "Ninja" \
  -DCMAKE_C_COMPILER=gcc \
  -DCMAKE_CXX_COMPILER=g++ \
  -DUHDR_BUILD_TESTS=1
cmake --build /tmp/libultrahdr-build
sudo cmake --install /tmp/libultrahdr-build
sudo ldconfig

# Configure CMake gcc
cmake -DENABLE_PNG=1 -DENABLE_FREETYPE=1 -DENABLE_JPEG=1 -DENABLE_ULTRAHDR=1 -DENABLE_WEBP=1 \
  -DENABLE_TIFF=1 -DENABLE_XPM=1 -DENABLE_GD_FORMATS=1 -DENABLE_HEIF=1 -DENABLE_AVIF=1 \
  -DBUILD_TEST=1 -B /workspace/build -DCMAKE_BUILD_TYPE=RELWITHDEBINFO

# Build
cmake --build /workspace/build --config RELWITHDEBINFO --parallel 4

# Test
cd /workspace/build
CTEST_OUTPUT_ON_FAILURE=1 ctest -C RELWITHDEBINFO

# Configure CMake ASAN
cmake -DENABLE_PNG=1 -DENABLE_FREETYPE=1 -DENABLE_JPEG=1 -DENABLE_ULTRAHDR=1 -DENABLE_WEBP=1 \
  -DENABLE_TIFF=1 -DENABLE_XPM=1 -DENABLE_GD_FORMATS=1 -DENABLE_HEIF=1 -DENABLE_AVIF=1 \
  -DBUILD_TEST=1 -B /workspace/buildasan -DCMAKE_BUILD_TYPE=RELWITHDEBINFO

# Build ASAN
cmake --build /workspace/buildasan --config RELWITHDEBINFO

# Test ASAN
cd /workspace/buildasan
CTEST_OUTPUT_ON_FAILURE=1 ctest -C RELWITHDEBINFO

# Configure and Make
cd /workspace
./bootstrap.sh
./configure --with-png --with-jpeg --with-heif --with-uhdr --with-xpm --with-tiff --with-webp --with-liq --enable-gd --enable-gd-formats --with-zlib
make
make dist

# Output Log
if test -f "/workspace/build/Testing/Temporary/LastTest.log"; then
  cat /workspace/build/Testing/Temporary/LastTest.log
fi