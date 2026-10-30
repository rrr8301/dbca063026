#!/bin/bash

set -e

# Track overall test status
OVERALL_STATUS=0

echo "=========================================="
echo "NCNN Linux x86 GCC Build & Test Suite"
echo "=========================================="

# Build 1: Default build with SSE2/AVX
echo ""
echo "=========================================="
echo "Build 1: Default (with SSE2/AVX)"
echo "=========================================="
mkdir -p build
cd build
cmake -DCMAKE_TOOLCHAIN_FILE=../toolchains/host.gcc-m32.toolchain.cmake \
       -DNCNN_BUILD_TESTS=ON \
       -DNCNN_BUILD_TOOLS=OFF \
       -DNCNN_BUILD_EXAMPLES=OFF \
       ..
cmake --build . -j $(nproc)
echo "Build 1 completed successfully"
cd ..

echo ""
echo "=========================================="
echo "Test 1: Default build tests"
echo "=========================================="
cd build
ctest --output-on-failure -j $(nproc) || OVERALL_STATUS=$?
cd ..

# Build 2: No SSE build
echo ""
echo "=========================================="
echo "Build 2: No SSE (RUNTIME_CPU=OFF, SSE2=OFF, AVX=OFF)"
echo "=========================================="
mkdir -p build-nosse
cd build-nosse
cmake -DCMAKE_TOOLCHAIN_FILE=../toolchains/host.gcc-m32.toolchain.cmake \
       -DNCNN_RUNTIME_CPU=OFF \
       -DNCNN_SSE2=OFF \
       -DNCNN_AVX=OFF \
       -DNCNN_BUILD_TESTS=ON \
       -DNCNN_BUILD_TOOLS=OFF \
       -DNCNN_BUILD_EXAMPLES=OFF \
       ..
cmake --build . -j $(nproc)
echo "Build 2 completed successfully"
cd ..

echo ""
echo "=========================================="
echo "Test 2: No SSE build tests"
echo "=========================================="
cd build-nosse
ctest --output-on-failure -j $(nproc) || OVERALL_STATUS=$?
cd ..

# Build 3: Shared library build
echo ""
echo "=========================================="
echo "Build 3: Shared Library"
echo "=========================================="
mkdir -p build-shared
cd build-shared
cmake -DCMAKE_TOOLCHAIN_FILE=../toolchains/host.gcc-m32.toolchain.cmake \
       -DNCNN_BUILD_TOOLS=OFF \
       -DNCNN_BUILD_EXAMPLES=OFF \
       -DNCNN_SHARED_LIB=ON \
       ..
cmake --build . -j $(nproc)
echo "Build 3 completed successfully"
cd ..

# Build 4: No INT8 build
echo ""
echo "=========================================="
echo "Build 4: No INT8 (INT8=OFF)"
echo "=========================================="
mkdir -p build-noint8
cd build-noint8
cmake -DCMAKE_TOOLCHAIN_FILE=../toolchains/host.gcc-m32.toolchain.cmake \
       -DNCNN_BUILD_TESTS=ON \
       -DNCNN_BUILD_TOOLS=OFF \
       -DNCNN_BUILD_EXAMPLES=OFF \
       -DNCNN_INT8=OFF \
       ..
cmake --build . -j $(nproc)
echo "Build 4 completed successfully"
cd ..

echo ""
echo "=========================================="
echo "Test 4: No INT8 build tests"
echo "=========================================="
cd build-noint8
ctest --output-on-failure -j $(nproc) || OVERALL_STATUS=$?
cd ..

echo ""
echo "=========================================="
echo "Build & Test Summary"
echo "=========================================="
if [ $OVERALL_STATUS -eq 0 ]; then
    echo "✓ All builds and tests completed successfully!"
    exit 0
else
    echo "✗ Some tests failed (exit code: $OVERALL_STATUS)"
    exit $OVERALL_STATUS
fi