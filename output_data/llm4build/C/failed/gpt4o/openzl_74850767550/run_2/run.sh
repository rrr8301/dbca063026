#!/bin/bash

# Check CMake version
cmake --version

# Configure CMake
mkdir -p build
cd build

CMAKE_ARGS="-DCMAKE_INSTALL_PREFIX=./install"

if [ -n "${BUILD_MODE}" ]; then
  CMAKE_ARGS="$CMAKE_ARGS -DOPENZL_BUILD_MODE=${BUILD_MODE}"
fi

if [ -n "${EXTRA_FLAGS}" ]; then
  CMAKE_ARGS="$CMAKE_ARGS -DZSTRONG_COMMON_FLAGS=\"${EXTRA_FLAGS}\""
fi

CMAKE_ARGS="$CMAKE_ARGS -DOPENZL_BUILD_TESTS=ON"

if [ "${SHARED_LIBS}" = "true" ]; then
  CMAKE_ARGS="$CMAKE_ARGS -DOPENZL_BUILD_SHARED_LIBS=ON"
fi

echo "Running: cmake $CMAKE_ARGS .."
cmake $CMAKE_ARGS ..

# Build
make -j2

# Test
ctest --output-on-failure