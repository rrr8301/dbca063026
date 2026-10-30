#!/bin/bash

set -e

# Compile LLVM C++ libraries (MSAN)
git clone --depth=1 --filter=blob:none https://github.com/llvm/llvm-project --no-checkout --branch release/20.x
cd llvm-project
git sparse-checkout init --cone
git sparse-checkout set cmake runtimes libc libcxx libcxxabi llvm/cmake
git checkout
cmake -S runtimes -B build -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi" \
  -DLLVM_USE_SANITIZER=MemoryWithOrigins \
  -DLIBCXXABI_USE_LLVM_UNWINDER=OFF \
  -DLIBCXX_ENABLE_STATIC=OFF \
  -DLIBCXX_INCLUDE_BENCHMARKS=OFF \
  -DLLVM_INCLUDE_TESTS=OFF \
  -DLLVM_INCLUDE_DOCS=OFF
cmake --build build -j5 -- cxx cxxabi
LLVM_BUILD_DIR=$(pwd)/build
cd ..

# Generate project files
cmake -S . -B build -DWITH_SANITIZER=Memory \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=OFF \
  -DWITH_FUZZERS=ON \
  -DWITH_MAINTAINER_WARNINGS=ON

# Compile source code
cmake --build build --verbose -j5 --config Release

# Run test cases
cd build
ctest --verbose -C Release -E benchmark_zlib --output-on-failure --max-width 120 -j 5