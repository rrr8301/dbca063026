#!/usr/bin/env bash
set -e

cd /app

# Static Debug
echo "=== Static Debug: Configure ==="
cmake -G Ninja -S . -B build-static-dbg -DCMAKE_BUILD_TYPE=Debug -DCMAKE_DEBUG_POSTFIX=d

echo "=== Static Debug: Build ==="
cmake --build build-static-dbg

echo "=== Static Debug: Test ==="
cd build-static-dbg
ctest --output-on-failure
cd ..

# Shared Debug
echo "=== Shared Debug: Configure ==="
cmake -G Ninja -S . -B build-shared-dbg -DCMAKE_BUILD_TYPE=Debug -DCMAKE_DEBUG_POSTFIX=d -DBUILD_SHARED_LIBS=ON

echo "=== Shared Debug: Build ==="
cmake --build build-shared-dbg

echo "=== Shared Debug: Test ==="
cd build-shared-dbg
ctest --output-on-failure
cd ..

# Static Release
echo "=== Static Release: Configure ==="
cmake -G Ninja -S . -B build-static-rel -DCMAKE_BUILD_TYPE=Release

echo "=== Static Release: Build ==="
cmake --build build-static-rel

echo "=== Static Release: Test ==="
cd build-static-rel
ctest --output-on-failure
cd ..

# Shared Release
echo "=== Shared Release: Configure ==="
cmake -G Ninja -S . -B build-shared-rel -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON

echo "=== Shared Release: Build ==="
cmake --build build-shared-rel

echo "=== Shared Release: Test ==="
cd build-shared-rel
ctest --output-on-failure
cd ..

# Install
echo "=== Install ==="
cmake --install build-shared-dbg --prefix install
cmake --install build-static-dbg --prefix install
cmake --install build-shared-rel --prefix install
cmake --install build-static-rel --prefix install

echo "=== List install tree ==="
tree install

# Test find_package: Static Debug
echo "=== Test find_package: Static Debug ==="
ctest --build-and-test test test-static-dbg \
  --build-generator Ninja \
  --build-options -DCMAKE_BUILD_TYPE=Debug -Dtinyxml2_SHARED_LIBS=NO -DCMAKE_PREFIX_PATH=/app/install \
  --test-command ctest --output-on-failure

# Test find_package: Static Release
echo "=== Test find_package: Static Release ==="
ctest --build-and-test test test-static-rel \
  --build-generator Ninja \
  --build-options -DCMAKE_BUILD_TYPE=Release -Dtinyxml2_SHARED_LIBS=NO -DCMAKE_PREFIX_PATH=/app/install \
  --test-command ctest --output-on-failure

# Test find_package: Shared Debug
echo "=== Test find_package: Shared Debug ==="
ctest --build-and-test test test-shared-dbg \
  --build-generator Ninja \
  --build-options -DCMAKE_BUILD_TYPE=Debug -Dtinyxml2_SHARED_LIBS=YES -DCMAKE_PREFIX_PATH=/app/install \
  --test-command ctest --output-on-failure

# Test find_package: Shared Release
echo "=== Test find_package: Shared Release ==="
ctest --build-and-test test test-shared-rel \
  --build-generator Ninja \
  --build-options -DCMAKE_BUILD_TYPE=Release -Dtinyxml2_SHARED_LIBS=YES -DCMAKE_PREFIX_PATH=/app/install \
  --test-command ctest --output-on-failure

echo "FINAL_STATUS = SUCCESS"
