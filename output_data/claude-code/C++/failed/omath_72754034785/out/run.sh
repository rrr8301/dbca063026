#!/usr/bin/env bash
set -e

echo "=== Configuring cmake ==="
cmake --preset linux-release-vcpkg \
  -DVCPKG_INSTALL_OPTIONS="--allow-unsupported" \
  -DOMATH_BUILD_TESTS=ON \
  -DOMATH_BUILD_BENCHMARK=OFF \
  -DOMATH_ENABLE_COVERAGE=ON \
  -DVCPKG_MANIFEST_FEATURES="imgui;avx2;tests;lua"

echo "=== Building unit_tests and omath ==="
cmake --build cmake-build/build/linux-release-vcpkg --target unit_tests omath

echo "=== Running unit_tests ==="
./out/Release/unit_tests

FINAL_STATUS=SUCCESS
echo "FINAL_STATUS = $FINAL_STATUS"
