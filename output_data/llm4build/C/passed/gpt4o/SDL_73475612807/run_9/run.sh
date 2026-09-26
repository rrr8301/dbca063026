#!/bin/bash

set -e

# Configure and build using CMake
cmake -S . -B build -G Ninja \
  -Wdeprecated -Wdev -Werror \
  -DSDL_WERROR=ON \
  -DSDL_EXAMPLES=ON \
  -DSDL_TESTS=ON \
  -DSDLTEST_TRACKMEM=ON \
  -DSDL_INSTALL_TESTS=ON \
  -DSDL_CLANG_TIDY=OFF \
  -DSDL_INSTALL_DOCS=ON \
  -DSDL_INSTALL_CPACK=ON \
  -DSDL_INSTALL_DOCS=ON \
  -DSDL_SHARED=ON \
  -DSDL_STATIC=OFF \
  -DSDL_VENDOR_INFO="Github Workflow" \
  -DCMAKE_INSTALL_PREFIX=prefix \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DCMAKE_BUILD_TYPE=Release

# Build the project
cmake --build build --config Release --verbose

# Run build-time tests
export SDL_TESTS_QUICK=1
ctest --test-dir build/ -VV -j2

# Install the project
cmake --install build --config Release

# Package the project
success=0
max_tries=10
for i in $(seq $max_tries); do
  cmake --build build/ --config Release --target package && success=1
  if test $success = 1; then
    break
  fi
  echo "Package creation failed. Sleep 1 second and try again."
  sleep 1
done
if test $success = 0; then
  echo "Package creation failed after $max_tries attempts."
  exit 1
fi

# Verify CMake configuration files
cmake -S cmake/test -B cmake_test_build -GNinja \
  -DTEST_SHARED=ON \
  -DTEST_STATIC=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH="$(pwd)/prefix"
cmake --build cmake_test_build --verbose --config Release

# Verify sdl3.pc
export PKG_CONFIG_PATH=$(pwd)/prefix/lib/pkgconfig
cmake/test/test_pkgconfig.sh