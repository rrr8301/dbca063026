#!/bin/bash
set -e

# Enable error handling: continue on test failures but track exit code
test_failed=0

echo "=== Running Debug build and tests ==="
cmake . -B out/debug -DCMAKE_BUILD_TYPE=Debug -DMI_DEBUG_FULL=ON
cmake --build out/debug --parallel 4 --config Debug
ctest --test-dir out/debug --verbose --timeout 240 -C Debug || test_failed=1

echo "=== Running Release build and tests ==="
cmake . -B out/release -DCMAKE_BUILD_TYPE=Release -DMI_OPT_ARCH=ON
cmake --build out/release --parallel 4 --config Release
ctest --test-dir out/release --verbose --timeout 240 -C Release || test_failed=1

echo "=== Running Secure build and tests ==="
cmake . -B out/secure -DCMAKE_BUILD_TYPE=Release -DMI_SECURE=ON
cmake --build out/secure --parallel 4 --config Release
ctest --test-dir out/secure --verbose --timeout 240 -C Release || test_failed=1

echo "=== Running Debug C++ build and tests ==="
cmake . -B out/debug-cxx -DCMAKE_BUILD_TYPE=Debug -DMI_DEBUG_FULL=ON -DMI_USE_CXX=ON
cmake --build out/debug-cxx --parallel 8 --config Debug
ctest --test-dir out/debug-cxx --verbose --timeout 240 -C Debug || test_failed=1

echo "=== Running Release C++ build and tests ==="
cmake . -B out/release-cxx -DCMAKE_BUILD_TYPE=Release -DMI_OPT_ARCH=ON -DMI_USE_CXX=ON
cmake --build out/release-cxx --parallel 8 --config Release
ctest --test-dir out/release-cxx --verbose --timeout 240 -C Release || test_failed=1

echo "=== Running Release C++ SIMD build and tests ==="
cmake . -B out/release-cxx -DCMAKE_BUILD_TYPE=Release -DMI_OPT_ARCH=ON -DMI_OPT_SIMD=ON -DMI_USE_CXX=ON
cmake --build out/release-cxx --parallel 8 --config Release
ctest --test-dir out/release-cxx --verbose --timeout 240 -C Release || test_failed=1

if [ $test_failed -ne 0 ]; then
    echo "=== Some tests failed ==="
    exit 1
fi

echo "=== All tests passed ==="
exit 0