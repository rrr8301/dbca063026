#!/usr/bin/env bash
set -e

echo "=== Building zlib-ng with Clang AARCH64 MSAN ==="

# Set environment variables
export LLVM_BUILD_DIR="${LLVM_BUILD_DIR:-/app/llvm-project/build}"
export CC=clang
export CXX=clang++
export CFLAGS=""
export CXXFLAGS=""
export LDFLAGS=""
export CI=true

# Environment variables for test execution
export ASAN_OPTIONS="verbosity=0:abort_on_error=1:halt_on_error=1"
export MSAN_OPTIONS="verbosity=0:abort_on_error=1:halt_on_error=1"
export TSAN_OPTIONS="verbosity=0:abort_on_error=1:halt_on_error=1"
export LSAN_OPTIONS="verbosity=0:abort_on_error=1:halt_on_error=1"
export UBSAN_OPTIONS="verbosity=0:print_stacktrace=1:abort_on_error=1:halt_on_error=1"

echo "Setting LLVM_BUILD_DIR=$LLVM_BUILD_DIR"

# Get latest LLVM hash
echo "Getting latest LLVM release/20.x hash..."
HASH=$(git ls-remote https://github.com/llvm/llvm-project refs/heads/release/20.x | cut -f1)
if [ -z "$HASH" ]; then
  echo "Failed to fetch LLVM remote hash, using default"
  HASH="default"
else
  echo "Using LLVM hash: $HASH"
fi

# Check if LLVM libraries are cached
if [ ! -d "$LLVM_BUILD_DIR/lib" ] || [ ! -d "$LLVM_BUILD_DIR/include" ]; then
  echo "LLVM C++ libraries not found, compiling..."

  # Use sparse-checkout to download only the folders we need (176MB instead of 2302MB)
  git clone --depth=1 --filter=blob:none https://github.com/llvm/llvm-project --no-checkout --branch release/20.x
  cd llvm-project
  git sparse-checkout set cmake runtimes libc libcxx libcxxabi llvm/cmake
  git checkout

  # Configure and build LLVM C++ libraries
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

  cd /app
  echo "LLVM C++ libraries compiled successfully"
else
  echo "LLVM C++ libraries found in cache"
fi

# Navigate to project root
cd /app

echo "Generating project files with CMake..."
cmake -S . \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=OFF \
  -DWITH_FUZZERS=ON \
  -DWITH_MAINTAINER_WARNINGS=ON \
  -DWITH_SANITIZER=Memory

echo "Compiling source code..."
cmake --build . --verbose -j5 --config Release

echo "Running test cases..."
ctest --verbose -C Release -E benchmark_zlib --output-on-failure --max-width 120 -j 5 || TEST_FAILED=1

if [ -z "$TEST_FAILED" ]; then
  echo "FINAL_STATUS = SUCCESS"
  exit 0
else
  echo "FINAL_STATUS = FAIL"
  exit 1
fi
