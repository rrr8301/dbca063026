#!/usr/bin/env bash

cd /app

export CC=gcc
export CXX=g++
export CFLAGS="-msse2"
export BUILD_TYPE=RELWITHDEBINFO
export TMP=/tmp

echo "=== Configuring CMake ==="
cmake -DENABLE_PNG=1 -DENABLE_FREETYPE=1 -DENABLE_JPEG=1 -DENABLE_WEBP=1 \
  -DENABLE_TIFF=1 -DENABLE_XPM=1 -DENABLE_GD_FORMATS=1 -DENABLE_HEIF=1 -DENABLE_RAQM=1 -DENABLE_AVIF=1 \
  -DBUILD_TEST=1 -B /app/build -DCMAKE_BUILD_TYPE=$BUILD_TYPE

if [ $? -ne 0 ]; then
  echo "FINAL_STATUS = FAIL"
  exit 1
fi

echo "=== Building ==="
cmake --build /app/build --config $BUILD_TYPE --parallel 4

if [ $? -ne 0 ]; then
  echo "FINAL_STATUS = FAIL"
  exit 1
fi

echo "=== Running Tests ==="
cd /app/build
export LSAN_OPTIONS="suppressions=/app/suppressions/lsan.supp"
CTEST_OUTPUT_ON_FAILURE=1 ctest -C $BUILD_TYPE
TEST_EXIT_CODE=$?

if [ -f "/app/build/Testing/Temporary/LastTest.log" ]; then
  echo "=== Test Log ==="
  cat /app/build/Testing/Temporary/LastTest.log
fi

# Tests ran if the test log exists
if [ -f "/app/build/Testing/Temporary/LastTest.log" ]; then
  echo "FINAL_STATUS = SUCCESS"
else
  echo "FINAL_STATUS = FAIL"
  exit 1
fi
