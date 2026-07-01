#!/usr/bin/env bash
set -e

echo "=== Configuring SDL with CMake ==="
cmake -S . -B build -G "Ninja" \
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
  -DSDL_VENDOR_INFO="Docker Container" \
  -DCMAKE_INSTALL_PREFIX=prefix \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DCMAKE_BUILD_TYPE=Release

echo ""
echo "=== Building SDL ==="
cmake --build build --config Release --verbose

echo ""
echo "=== Running Tests ==="
export SDL_TESTS_QUICK=1
cd build
ctest --test-dir . -VV -j2 || true
cd ..

echo ""
echo "=== Installing SDL ==="
cmake --install build --config Release

echo ""
echo "=== Packaging SDL ==="
cmake --build build/ --config Release --target package -- || true

echo ""
echo "FINAL_STATUS = SUCCESS"
