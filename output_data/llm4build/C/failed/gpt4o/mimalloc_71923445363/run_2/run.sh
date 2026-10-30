#!/bin/bash

set -e

# Set the compiler to clang-14
export CC=clang-14
export CXX=clang++-14

# Build and test configurations
build_and_test() {
  local build_dir=$1
  local build_type=$2
  local cmake_options=$3

  cmake . -B "$build_dir" -DCMAKE_BUILD_TYPE="$build_type" $cmake_options
  cmake --build "$build_dir" --parallel 8 --config "$build_type"
  ctest --test-dir "$build_dir" --verbose --timeout 240 -C "$build_type"
}

# Release, SIMD
build_and_test "out/release-simd" "Release" "-DMI_OPT_ARCH=ON -DMI_OPT_SIMD=ON"

# Debug, C++, clang++
build_and_test "out/debug-clang-cxx" "Debug" "-DMI_DEBUG_FULL=ON -DMI_USE_CXX=ON"

# Release, C++, clang++
build_and_test "out/release-clang-cxx" "Release" "-DMI_OPT_ARCH=ON -DMI_USE_CXX=ON"

# Debug, ASAN
build_and_test "out/debug-asan" "Debug" "-DMI_DEBUG_FULL=ON -DMI_TRACK_ASAN=ON"

# Debug, UBSAN
build_and_test "out/debug-ubsan" "Debug" "-DMI_DEBUG_FULL=ON -DMI_DEBUG_UBSAN=ON"

# Debug, TSAN
build_and_test "out/debug-tsan" "Debug" "-DMI_DEBUG_FULL=ON -DMI_DEBUG_TSAN=ON"