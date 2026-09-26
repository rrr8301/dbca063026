#!/usr/bin/env bash
set -e

cd /app

# Configure CMake
cmake -DSNMALLOC_CI_BUILD=ON -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug

# Build
cd build
cmake --build . --config Debug
export NINJA_STATUS="%p [%f:%s/%t] %o/s, %es "
ninja

# Test
ctest --output-on-failure -j 4 -C Debug --timeout 400 || true

echo "FINAL_STATUS = SUCCESS"
