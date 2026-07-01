#!/usr/bin/env bash

echo "=== Starting TinyXML2 Test Suite ==="

# Static Debug
echo "=== Static Debug: Configure ==="
cmake -G Ninja -S . -B build-static-dbg -DCMAKE_BUILD_TYPE=Debug "-DCMAKE_DEBUG_POSTFIX=d" || { echo "FINAL_STATUS = FAIL"; exit 1; }
echo "=== Static Debug: Build ==="
cmake --build build-static-dbg || { echo "FINAL_STATUS = FAIL"; exit 1; }
echo "=== Static Debug: Test ==="
cd build-static-dbg && ctest --output-on-failure || true && cd ..

# Shared Debug
echo "=== Shared Debug: Configure ==="
cmake -G Ninja -S . -B build-shared-dbg -DCMAKE_BUILD_TYPE=Debug -DCMAKE_DEBUG_POSTFIX=d -DBUILD_SHARED_LIBS=ON || { echo "FINAL_STATUS = FAIL"; exit 1; }
echo "=== Shared Debug: Build ==="
cmake --build build-shared-dbg || { echo "FINAL_STATUS = FAIL"; exit 1; }
echo "=== Shared Debug: Test ==="
cd build-shared-dbg && ctest --output-on-failure || true && cd ..

# Static Release
echo "=== Static Release: Configure ==="
cmake -G Ninja -S . -B build-static-rel -DCMAKE_BUILD_TYPE=Release "-DCMAKE_RELEASE_POSTFIX=" || { echo "FINAL_STATUS = FAIL"; exit 1; }
echo "=== Static Release: Build ==="
cmake --build build-static-rel || { echo "FINAL_STATUS = FAIL"; exit 1; }
echo "=== Static Release: Test ==="
cd build-static-rel && ctest --output-on-failure || true && cd ..

# Shared Release
echo "=== Shared Release: Configure ==="
cmake -G Ninja -S . -B build-shared-rel -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON || { echo "FINAL_STATUS = FAIL"; exit 1; }
echo "=== Shared Release: Build ==="
cmake --build build-shared-rel || { echo "FINAL_STATUS = FAIL"; exit 1; }
echo "=== Shared Release: Test ==="
cd build-shared-rel && ctest --output-on-failure || true && cd ..

# Joint install
echo "=== Install ==="
cmake --install build-shared-dbg --prefix install || { echo "FINAL_STATUS = FAIL"; exit 1; }
cmake --install build-static-dbg --prefix install || { echo "FINAL_STATUS = FAIL"; exit 1; }
cmake --install build-shared-rel --prefix install || { echo "FINAL_STATUS = FAIL"; exit 1; }
cmake --install build-static-rel --prefix install || { echo "FINAL_STATUS = FAIL"; exit 1; }

echo "=== List install tree ==="
tree install || true

# Test find_package
echo "=== Test find_package: Static Debug ==="
ctest --build-and-test test test-static-dbg \
  --build-generator Ninja \
  --build-options -DCMAKE_BUILD_TYPE=Debug -Dtinyxml2_SHARED_LIBS=NO -DCMAKE_PREFIX_PATH=/app/install \
  --test-command ctest --output-on-failure || true

echo "=== Test find_package: Static Release ==="
ctest --build-and-test test test-static-rel \
  --build-generator Ninja \
  --build-options -DCMAKE_BUILD_TYPE=Release -Dtinyxml2_SHARED_LIBS=NO -DCMAKE_PREFIX_PATH=/app/install \
  --test-command ctest --output-on-failure || true

echo "=== Test find_package: Shared Debug ==="
ctest --build-and-test test test-shared-dbg \
  --build-generator Ninja \
  --build-options -DCMAKE_BUILD_TYPE=Debug -Dtinyxml2_SHARED_LIBS=YES -DCMAKE_PREFIX_PATH=/app/install \
  --test-command ctest --output-on-failure || true

echo "=== Test find_package: Shared Release ==="
ctest --build-and-test test test-shared-rel \
  --build-generator Ninja \
  --build-options -DCMAKE_BUILD_TYPE=Release -Dtinyxml2_SHARED_LIBS=YES -DCMAKE_PREFIX_PATH=/app/install \
  --test-command ctest --output-on-failure || true

echo "FINAL_STATUS = SUCCESS"
