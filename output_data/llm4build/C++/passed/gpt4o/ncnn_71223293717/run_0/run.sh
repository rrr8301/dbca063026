#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Build and test configurations
build_and_test() {
    local build_dir=$1
    local cmake_options=$2

    mkdir -p $build_dir && cd $build_dir
    cmake $cmake_options ..
    cmake --build . -j $(nproc)
    ctest --output-on-failure -j $(nproc)
    cd ..
}

# Main script execution
build_and_test build "-DCMAKE_TOOLCHAIN_FILE=../toolchains/host.gcc-m32.toolchain.cmake -DNCNN_BUILD_TESTS=ON -DNCNN_BUILD_TOOLS=OFF -DNCNN_BUILD_EXAMPLES=OFF"
build_and_test build-nosse "-DCMAKE_TOOLCHAIN_FILE=../toolchains/host.gcc-m32.toolchain.cmake -DNCNN_RUNTIME_CPU=OFF -DNCNN_SSE2=OFF -DNCNN_AVX=OFF -DNCNN_BUILD_TESTS=ON -DNCNN_BUILD_TOOLS=OFF -DNCNN_BUILD_EXAMPLES=OFF"
build_and_test build-shared "-DCMAKE_TOOLCHAIN_FILE=../toolchains/host.gcc-m32.toolchain.cmake -DNCNN_BUILD_TOOLS=OFF -DNCNN_BUILD_EXAMPLES=OFF -DNCNN_SHARED_LIB=ON"
build_and_test build-noint8 "-DCMAKE_TOOLCHAIN_FILE=../toolchains/host.gcc-m32.toolchain.cmake -DNCNN_BUILD_TESTS=ON -DNCNN_BUILD_TOOLS=OFF -DNCNN_BUILD_EXAMPLES=OFF -DNCNN_INT8=OFF"