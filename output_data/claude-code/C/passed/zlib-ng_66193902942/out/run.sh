#!/usr/bin/env bash
set -e

cd /app

export CC=gcc
export CXX=g++
export CI=true

# Generate project files
cmake -S . -DWITH_SANITIZER=Address -DWITH_BENCHMARKS=ON \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=OFF \
  -DWITH_FUZZERS=ON \
  -DWITH_MAINTAINER_WARNINGS=ON \
  -DWITH_CODE_COVERAGE=ON

# Compile source code
cmake --build . --verbose -j2 --config Release

# Run test cases
export ASAN_OPTIONS="verbosity=0:abort_on_error=1:halt_on_error=1"
export MSAN_OPTIONS="verbosity=0:abort_on_error=1:halt_on_error=1"
export TSAN_OPTIONS="verbosity=0:abort_on_error=1:halt_on_error=1"
export LSAN_OPTIONS="verbosity=0:abort_on_error=1:halt_on_error=1"
export UBSAN_OPTIONS="verbosity=0:print_stacktrace=1:abort_on_error=1:halt_on_error=1"

ctest --verbose -C Release -E benchmark_zlib --output-on-failure --max-width 120 -j 3

# Test benchmarks (crashtest only)
ctest --verbose -C Release -R ^benchmark_zlib$ --output-on-failure --max-width 120 -j 3

echo "FINAL_STATUS = SUCCESS"
