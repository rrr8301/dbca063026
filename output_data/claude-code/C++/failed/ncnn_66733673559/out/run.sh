#!/usr/bin/env bash

set -e

export CC=clang
export CXX=clang++

# Build SSE2
echo "Building SSE2..."
mkdir -p build-sse2 && cd build-sse2
cmake -DNCNN_AVX=OFF -DNCNN_AVX2=OFF -DNCNN_BUILD_TESTS=ON ..
cmake --build . -j $(nproc)
cd ..

# Test SSE2
echo "Testing SSE2..."
cd build-sse2
if ctest --output-on-failure -j $(nproc); then
  echo "SSE2 tests passed"
else
  echo "SSE2 tests failed"
fi
cd ..

# Build shared
echo "Building shared..."
mkdir -p build-shared && cd build-shared
cmake -DNCNN_AVX2=ON -DNCNN_SHARED_LIB=ON ..
cmake --build . -j $(nproc)
cd ..

# Build AVX2
echo "Building AVX2..."
mkdir -p build-avx2 && cd build-avx2
cmake -DNCNN_AVX2=ON -DNCNN_BUILD_TESTS=ON ..
cmake --build . -j $(nproc)
cd ..

# Test AVX2
echo "Testing AVX2..."
cd build-avx2
if ctest --output-on-failure -j $(nproc); then
  echo "AVX2 tests passed"
else
  echo "AVX2 tests failed"
fi
cd ..

# Build AVX
echo "Building AVX..."
mkdir -p build-avx && cd build-avx
cmake -DNCNN_AVX2=OFF -DNCNN_AVX=ON -DNCNN_BUILD_TESTS=ON ..
cmake --build . -j $(nproc)
cd ..

# Test AVX
echo "Testing AVX..."
cd build-avx
if ctest --output-on-failure -j $(nproc); then
  echo "AVX tests passed"
else
  echo "AVX tests failed"
fi
cd ..

# Build AVX1-2
echo "Building AVX1-2..."
mkdir -p build-avx1-2 && cd build-avx1-2
cmake -DNCNN_AVX2=ON -DNCNN_AVX=ON -DNCNN_BUILD_TESTS=ON ..
cmake --build . -j $(nproc)
cd ..

# Test AVX1-2
echo "Testing AVX1-2..."
cd build-avx1-2
if ctest --output-on-failure -j $(nproc); then
  echo "AVX1-2 tests passed"
else
  echo "AVX1-2 tests failed"
fi
cd ..

# Build noint8
echo "Building noint8..."
mkdir -p build-noint8 && cd build-noint8
cmake -DNCNN_INT8=OFF -DNCNN_BUILD_TESTS=ON ..
cmake --build . -j $(nproc)
cd ..

# Test noint8
echo "Testing noint8..."
cd build-noint8
if ctest --output-on-failure -j $(nproc); then
  echo "noint8 tests passed"
else
  echo "noint8 tests failed"
fi
cd ..

echo "FINAL_STATUS = SUCCESS"
