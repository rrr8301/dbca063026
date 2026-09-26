#!/bin/bash

# Clone the repository
git clone <repository-url> /workspace
cd /workspace

# Debug
cmake . -B out/debug -DCMAKE_BUILD_TYPE=Debug -DMI_DEBUG_FULL=ON
cmake --build out/debug --parallel 4 --config Debug
ctest --test-dir out/debug --verbose --timeout 240 -C Debug

# Release
cmake . -B out/release -DCMAKE_BUILD_TYPE=Release -DMI_OPT_ARCH=ON
cmake --build out/release --parallel 4 --config Release
ctest --test-dir out/release --verbose --timeout 240 -C Release

# Secure
cmake . -B out/secure -DCMAKE_BUILD_TYPE=Release -DMI_SECURE=ON
cmake --build out/secure --parallel 4 --config Release
ctest --test-dir out/secure --verbose --timeout 240 -C Release

# Debug, C++
cmake . -B out/debug-cxx -DCMAKE_BUILD_TYPE=Debug -DMI_DEBUG_FULL=ON -DMI_USE_CXX=ON
cmake --build out/debug-cxx --parallel 8 --config Debug
ctest --test-dir out/debug-cxx --verbose --timeout 240 -C Debug

# Release, C++
cmake . -B out/release-cxx -DCMAKE_BUILD_TYPE=Release -DMI_OPT_ARCH=ON -DMI_USE_CXX=ON
cmake --build out/release-cxx --parallel 8 --config Release
ctest --test-dir out/release-cxx --verbose --timeout 240 -C Release

# Release, C++, SIMD
cmake . -B out/release-cxx -DCMAKE_BUILD_TYPE=Release -DMI_OPT_ARCH=ON -DMI_OPT_SIMD=ON -DMI_USE_CXX=ON
cmake --build out/release-cxx --parallel 8 --config Release
ctest --test-dir out/release-cxx --verbose --timeout 240 -C Release