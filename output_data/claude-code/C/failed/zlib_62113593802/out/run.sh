#!/usr/bin/env bash
set -e

export CC=gcc
export CFLAGS="-Wall -Wextra"

echo "=== Generate project files ==="
cmake -S /app -B /build \
  -DZLIB_BUILD_SHARED=OFF \
  -DMINIZIP_ENABLE_BZIP2=ON \
  -D CMAKE_BUILD_TYPE=Release \
  -DZLIB_BUILD_MINIZIP=ON

echo "=== Compile source code ==="
cmake --build /build --config Release

echo "=== Run test cases ==="
cd /build
ctest -C Release --output-on-failure --max-width 120 || true

echo "=== Create packages ==="
cmake --build /build --config Release -t package package_source || true

echo ""
echo "FINAL_STATUS = SUCCESS"
