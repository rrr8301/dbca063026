#!/usr/bin/env bash
set -e

echo "=== Checking CMake version ==="
cmake --version

echo "=== Configuring CMake ==="
cmake -E make_directory /app/build
cd /app/build

CMAKE_ARGS="-DCMAKE_INSTALL_PREFIX=./install"
CMAKE_ARGS="$CMAKE_ARGS -DZSTRONG_COMMON_FLAGS=\"-Werror\""
CMAKE_ARGS="$CMAKE_ARGS -DOPENZL_BUILD_TESTS=ON"
CMAKE_ARGS="$CMAKE_ARGS -DOPENZL_BUILD_SHARED_LIBS=ON"

echo "Running: cmake $CMAKE_ARGS .."
cmake $CMAKE_ARGS ..

echo "=== Building ==="
make -j2

echo "=== Running tests ==="
ctest --output-on-failure

echo "=== Installing ==="
make install

echo "FINAL_STATUS = SUCCESS"
