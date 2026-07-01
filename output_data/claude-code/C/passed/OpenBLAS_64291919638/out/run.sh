#!/usr/bin/env bash

set -e

CC="clang-21"
FC="gfortran"
BUILD_TYPE="cmake"

echo "=== Print system information ==="
cat /proc/cpuinfo || true

echo "=== Configure ccache ==="
test -d ~/.ccache || mkdir -p ~/.ccache
echo "max_size = 300M" > ~/.ccache/ccache.conf
echo "compression = true" >> ~/.ccache/ccache.conf
ccache -s

echo "=== Build OpenBLAS ==="
mkdir -p build
cd build
cmake -DDYNAMIC_ARCH=1 \
      -DNOFORTRAN=0 \
      -DBUILD_WITHOUT_LAPACK=0 \
      -DCMAKE_VERBOSE_MAKEFILE=ON \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_C_COMPILER=$CC \
      -DCMAKE_Fortran_COMPILER=$FC \
      -DCMAKE_C_COMPILER_LAUNCHER=ccache \
      -DCMAKE_Fortran_COMPILER_LAUNCHER=ccache \
      ..
cmake --build .

echo "=== Show ccache status ==="
ccache -s || true

echo "=== Run tests ==="
ctest

echo "FINAL_STATUS = SUCCESS"
