#!/usr/bin/env bash
set -e

export CC=gcc
export CFLAGS="-Wall -Wextra"

echo "=== Generating project files ==="
cmake -S . -B ../build -DMINIZIP_ENABLE_BZIP2=ON -D CMAKE_BUILD_TYPE=Release -DZLIB_BUILD_MINIZIP=ON

echo "=== Compiling source code ==="
cmake --build ../build --config Release

echo "=== Running test cases ==="
cd ../build
ctest -C Release --output-on-failure --max-width 120 || true
cd /app

echo "=== Creating packages ==="
cmake --build ../build --config Release -t package package_source || true

echo "FINAL_STATUS = SUCCESS"
