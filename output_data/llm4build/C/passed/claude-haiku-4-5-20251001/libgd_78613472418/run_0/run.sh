#!/bin/bash
set -e

# Set environment variables
export CC=gcc
export CXX=g++
export CFLAGS="-msse2"
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:${PKG_CONFIG_PATH}
export TMP=/tmp
export LSAN_OPTIONS="suppressions=/workspace/suppressions/lsan.supp"
export CTEST_OUTPUT_ON_FAILURE=1

cd /workspace

# Debug CC Env
echo "CC: $CC"
echo "CXX: $CXX"
echo "CFLAGS: $CFLAGS"

# ============================================================================
# CMake Build (GCC) - Normal
# ============================================================================
echo "=== Configuring CMake (GCC) ==="
cmake -DENABLE_PNG=1 -DENABLE_FREETYPE=1 -DENABLE_JPEG=1 -DENABLE_ULTRAHDR=1 -DENABLE_WEBP=1 \
  -DENABLE_TIFF=1 -DENABLE_XPM=1 -DENABLE_GD_FORMATS=1 -DENABLE_HEIF=1 -DENABLE_AVIF=1 \
  -DBUILD_TEST=1 -B /workspace/build -DCMAKE_BUILD_TYPE=RELWITHDEBINFO

echo "=== Building (GCC) ==="
cmake --build /workspace/build --config RELWITHDEBINFO --parallel 4

echo "=== Testing (GCC) ==="
cd /workspace/build
ctest -C RELWITHDEBINFO || true
cd /workspace

# ============================================================================
# CMake Build (ASAN)
# ============================================================================
echo "=== Configuring CMake (ASAN) ==="
cmake -DENABLE_PNG=1 -DENABLE_FREETYPE=1 -DENABLE_JPEG=1 -DENABLE_ULTRAHDR=1 -DENABLE_WEBP=1 \
  -DENABLE_TIFF=1 -DENABLE_XPM=1 -DENABLE_GD_FORMATS=1 -DENABLE_HEIF=1 -DENABLE_AVIF=1 \
  -DBUILD_TEST=1 -B /workspace/buildasan -DCMAKE_BUILD_TYPE=RELWITHDEBINFO

echo "=== Building (ASAN) ==="
export CFLAGS="-march=armv8.2-a+fp16+rcpc+dotprod+crypto -mtune=neoverse-n1"
cmake --build /workspace/buildasan --config RELWITHDEBINFO || true

echo "=== Testing (ASAN) ==="
cd /workspace/buildasan
ctest -C RELWITHDEBINFO || true
cd /workspace

# ============================================================================
# Autotools Build
# ============================================================================
echo "=== Running bootstrap.sh ==="
./bootstrap.sh

echo "=== Running configure ==="
./configure --with-png --with-jpeg --with-heif --with-uhdr --with-xpm --with-tiff --with-webp --with-liq --enable-gd --enable-gd-formats --with-zlib

echo "=== Running make ==="
make

echo "=== Running make dist ==="
make dist || true

# ============================================================================
# Output Log
# ============================================================================
echo "=== Checking for test logs ==="
if test -f "/workspace/build/Testing/Temporary/LastTest.log"; then
  echo "=== LastTest.log ==="
  cat /workspace/build/Testing/Temporary/LastTest.log
fi

echo "=== Build and test completed ==="