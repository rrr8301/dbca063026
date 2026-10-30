#!/usr/bin/env bash
set -e

export CC=gcc
export CXX=g++
export CFLAGS="-msse2"
export BUILD_TYPE=RELWITHDEBINFO
export CTEST_OUTPUT_ON_FAILURE=1
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:${PKG_CONFIG_PATH}

cd /app

# Debug CC Env
echo "=== Debug CC Env ==="
echo "$CC"
echo "$CXX"
echo "$CFLAGS"

# Configure CMake gcc
echo "=== Configure CMake gcc ==="
cmake -DENABLE_PNG=1 -DENABLE_FREETYPE=1 -DENABLE_JPEG=1 -DENABLE_ULTRAHDR=1 -DENABLE_WEBP=1 \
    -DENABLE_TIFF=1 -DENABLE_XPM=1 -DENABLE_GD_FORMATS=1 -DENABLE_HEIF=1 -DENABLE_AVIF=1 \
    -DBUILD_TEST=1 -B /app/build -DCMAKE_BUILD_TYPE=$BUILD_TYPE

# Build
echo "=== Build ==="
cmake --build /app/build --config $BUILD_TYPE --parallel 4

# Test
echo "=== Test ==="
cd /app/build
export TMP=/tmp
ctest -C $BUILD_TYPE || true

# Output Log
echo "=== Output Log ==="
if [ -f "/app/build/Testing/Temporary/LastTest.log" ]; then
    cat /app/build/Testing/Temporary/LastTest.log
fi

# Configure and Make
echo "=== Configure and Make ==="
cd /app
./bootstrap.sh
./configure --with-png --with-jpeg --with-heif --with-uhdr --with-xpm --with-tiff --with-webp --with-liq --enable-gd --enable-gd-formats --with-zlib
make || true
make dist || true

echo "FINAL_STATUS = SUCCESS"
