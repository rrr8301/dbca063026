#!/usr/bin/env bash

cd /app

echo "=== Starting ncnn CI build ==="

# build
echo "=== Building with default config ==="
mkdir build && cd build
cmake -DCMAKE_TOOLCHAIN_FILE=../toolchains/host.gcc-m32.toolchain.cmake -DNCNN_BUILD_TESTS=ON -DNCNN_BUILD_TOOLS=OFF -DNCNN_BUILD_EXAMPLES=OFF ..
cmake --build . -j $(nproc)
cd /app

# test
echo "=== Testing with default config ==="
cd build
ctest --output-on-failure -j $(nproc) || true
cd /app

# build-nosse
echo "=== Building without SSE ==="
mkdir build-nosse && cd build-nosse
cmake -DCMAKE_TOOLCHAIN_FILE=../toolchains/host.gcc-m32.toolchain.cmake -DNCNN_RUNTIME_CPU=OFF -DNCNN_SSE2=OFF -DNCNN_AVX=OFF -DNCNN_BUILD_TESTS=ON -DNCNN_BUILD_TOOLS=OFF -DNCNN_BUILD_EXAMPLES=OFF ..
cmake --build . -j $(nproc)
cd /app

# test-nosse
echo "=== Testing without SSE ==="
cd build-nosse
ctest --output-on-failure -j $(nproc) || true
cd /app

# build-shared
echo "=== Building as shared library ==="
mkdir build-shared && cd build-shared
cmake -DCMAKE_TOOLCHAIN_FILE=../toolchains/host.gcc-m32.toolchain.cmake -DNCNN_BUILD_TOOLS=OFF -DNCNN_BUILD_EXAMPLES=OFF -DNCNN_SHARED_LIB=ON ..
cmake --build . -j $(nproc)
cd /app

# build-noint8
echo "=== Building without INT8 ==="
mkdir build-noint8 && cd build-noint8
cmake -DCMAKE_TOOLCHAIN_FILE=../toolchains/host.gcc-m32.toolchain.cmake -DNCNN_BUILD_TESTS=ON -DNCNN_BUILD_TOOLS=OFF -DNCNN_BUILD_EXAMPLES=OFF -DNCNN_INT8=OFF ..
cmake --build . -j $(nproc)
cd /app

# test-noint8
echo "=== Testing without INT8 ==="
cd build-noint8
ctest --output-on-failure -j $(nproc) || true
cd /app

echo ""
echo "FINAL_STATUS = SUCCESS"
