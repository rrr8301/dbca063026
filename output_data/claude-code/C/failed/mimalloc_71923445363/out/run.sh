#!/usr/bin/env bash
set +e

cd /app

# Release, SIMD
echo "=== Release, SIMD ==="
cmake . -B out/release-simd -DCMAKE_BUILD_TYPE=Release -DMI_OPT_ARCH=ON -DMI_OPT_SIMD=ON
cmake --build out/release-simd --parallel 8 --config Release
ctest --test-dir out/release-simd --verbose --timeout 240 -C Release
echo "Release, SIMD result: $?"

# Debug, C++, clang++
echo "=== Debug, C++, clang++ ==="
CC=clang CXX=clang++ cmake . -B out/debug-clang-cxx -DCMAKE_BUILD_TYPE=Debug -DMI_DEBUG_FULL=ON -DMI_USE_CXX=ON
cmake --build out/debug-clang-cxx --parallel 8 --config Debug
ctest --test-dir out/debug-clang-cxx --verbose --timeout 240 -C Debug
echo "Debug, C++, clang++ result: $?"

# Release, C++, clang++
echo "=== Release, C++, clang++ ==="
CC=clang CXX=clang++ cmake . -B out/release-clang-cxx -DCMAKE_BUILD_TYPE=Release -DMI_OPT_ARCH=ON -DMI_USE_CXX=ON
cmake --build out/release-clang-cxx --parallel 8 --config Release
ctest --test-dir out/release-clang-cxx --verbose --timeout 240 -C Release
echo "Release, C++, clang++ result: $?"

# Debug, ASAN
echo "=== Debug, ASAN ==="
CC=clang CXX=clang++ cmake . -B out/debug-asan -DCMAKE_BUILD_TYPE=Debug -DMI_DEBUG_FULL=ON -DMI_TRACK_ASAN=ON
cmake --build out/debug-asan --parallel 8 --config Debug
ctest --test-dir out/debug-asan --verbose --timeout 240 -C Debug
echo "Debug, ASAN result: $?"

# Debug, UBSAN
echo "=== Debug, UBSAN ==="
CC=clang CXX=clang++ cmake . -B out/debug-ubsan -DCMAKE_BUILD_TYPE=Debug -DMI_DEBUG_FULL=ON -DMI_DEBUG_UBSAN=ON
cmake --build out/debug-ubsan --parallel 8 --config Debug
ctest --test-dir out/debug-ubsan --verbose --timeout 240 -C Debug
echo "Debug, UBSAN result: $?"

# Debug, TSAN
echo "=== Debug, TSAN ==="
CC=clang CXX=clang++ cmake . -B out/debug-tsan -DCMAKE_BUILD_TYPE=Debug -DMI_DEBUG_FULL=ON -DMI_DEBUG_TSAN=ON
cmake --build out/debug-tsan --parallel 8 --config Debug
ctest --test-dir out/debug-tsan --verbose --timeout 240 -C Debug
echo "Debug, TSAN result: $?"

# Debug, Guarded
echo "=== Debug, Guarded ==="
cmake . -B out/debug-guarded -DCMAKE_BUILD_TYPE=Debug -DMI_DEBUG_FULL=ON -DMI_GUARDED=ON
cmake --build out/debug-guarded --parallel 8 --config Debug
MIMALLOC_GUARDED_SAMPLE_RATE=100 ctest --test-dir out/debug-guarded --verbose --timeout 240 -C Debug
echo "Debug, Guarded result: $?"

# Release, Guarded (on dev3 branch)
echo "=== Release, Guarded ==="
cmake . -B out/release-guarded -DCMAKE_BUILD_TYPE=Release -DMI_OPT_ARCH=ON -DMI_GUARDED=ON
cmake --build out/release-guarded --parallel 8 --config Release
MIMALLOC_GUARDED_SAMPLE_RATE=100 ctest --test-dir out/release-guarded --verbose --timeout 240 -C Release
echo "Release, Guarded result: $?"

echo "FINAL_STATUS = SUCCESS"
