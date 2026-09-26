#!/bin/bash
set -e

# Set environment variables
export TERM=xterm-256color
export GTEST_COLOR=1
export CC=clang
export CXX=clang++
export CI=true
export CFLAGS="-O2"

# Sanitizer options
export ASAN_OPTIONS="verbosity=0:abort_on_error=1:halt_on_error=1"
export MSAN_OPTIONS="verbosity=0:abort_on_error=1:halt_on_error=1"
export TSAN_OPTIONS="verbosity=0:abort_on_error=1:halt_on_error=1"
export LSAN_OPTIONS="verbosity=0:abort_on_error=1:halt_on_error=1"
export UBSAN_OPTIONS="verbosity=0:print_stacktrace=1:abort_on_error=1:halt_on_error=1"

cd /workspace

# Compile LLVM C++ libraries (MSAN)
echo "=== Compiling LLVM C++ libraries (MSAN) ==="
git clone --depth=1 --filter=blob:none https://github.com/llvm/llvm-project --no-checkout --branch release/20.x
cd llvm-project
git sparse-checkout set cmake runtimes libc libcxx libcxxabi llvm/cmake
git checkout

# Build runtimes with MSAN
echo "=== Building libcxx and libcxxabi with MSAN ==="
cmake -S runtimes -B build -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi" \
  -DLLVM_USE_SANITIZER=MemoryWithOrigins \
  -DLIBCXXABI_USE_LLVM_UNWINDER=OFF \
  -DLIBCXX_ENABLE_STATIC=OFF \
  -DLIBCXX_INCLUDE_BENCHMARKS=OFF \
  -DLLVM_INCLUDE_TESTS=OFF \
  -DLLVM_INCLUDE_DOCS=OFF \
  -DLIBC_INCLUDE_BENCHMARKS=OFF \
  -DLIBC_INCLUDE_TESTS=OFF
cmake --build build -j5 -- cxx cxxabi
export LLVM_BUILD_DIR="$(pwd)/build"
cd /workspace

# Generate project files
echo "=== Generating CMake project files ==="
cmake -S . \
  -DWITH_SANITIZER=Memory \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=OFF \
  -DWITH_FUZZERS=ON \
  -DWITH_MAINTAINER_WARNINGS=ON \
  -DCMAKE_CXX_FLAGS="-fsanitize=memory -fsanitize-memory-track-origins" \
  -DCMAKE_C_FLAGS="-fsanitize=memory -fsanitize-memory-track-origins"

# Compile source code
echo "=== Compiling source code ==="
cmake --build . --verbose -j5 --config Release

# Run test cases
echo "=== Running test cases ==="
ctest --verbose -C Release -E benchmark_zlib --output-on-failure --max-width 120 -j 5

echo "=== All tests completed ==="