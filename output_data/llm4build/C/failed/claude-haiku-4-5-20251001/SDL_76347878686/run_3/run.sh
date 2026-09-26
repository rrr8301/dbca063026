#!/bin/bash
set -eu

echo "Building level2 / Ubuntu (latest)"

# Configure CMake
cmake -S . -B build -G "Unix Makefiles" \
  -Wdeprecated -Wdev -Werror \
  -DSDL_WERROR=ON \
  -DSDL_EXAMPLES=ON \
  -DSDL_TESTS=ON \
  -DSDLTEST_TRACKMEM=ON \
  -DSDL_INSTALL_TESTS=ON \
  -DSDL_CLANG_TIDY=OFF \
  -DSDL_INSTALL_DOCS=ON \
  -DSDL_INSTALL_CPACK=ON \
  -DSDL_SHARED=ON \
  -DSDL_STATIC=ON \
  -DSDL_VENDOR_INFO="Github Workflow" \
  -DCMAKE_INSTALL_PREFIX=prefix \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DCMAKE_BUILD_TYPE=Release

# Build with CMake
cmake --build build --config Release --verbose

# Verify SDL_REVISION
echo "This should show us the SDL_REVISION"
echo "Shared library:"
strings build/libSDL3.so | grep "Github Workflow" || echo "<Shared library not found>"
echo "Static library:"
strings build/libSDL3.a | grep "Github Workflow" || echo "<Static library not found>"

# Run build-time tests (CMake)
export SDL_TESTS_QUICK=1
ctest --test-dir build/ -VV -j2

# Install (CMake)
cmake --install build --config Release
echo "Installation prefix: $(pwd)/prefix"
( cd prefix; find . ) | LC_ALL=C sort -u

# Package (CPack)
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

echo "Build completed successfully!"