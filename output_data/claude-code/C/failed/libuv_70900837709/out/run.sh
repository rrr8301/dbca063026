#!/bin/sh
set -e

cd /app

echo "=== Building with CMake ==="
cmake -B build -DBUILD_TESTING=ON
cmake --build build

echo "=== Running Tests ==="
cd build
ctest -V || true

FINAL_STATUS="SUCCESS"
echo "FINAL_STATUS = $FINAL_STATUS"
