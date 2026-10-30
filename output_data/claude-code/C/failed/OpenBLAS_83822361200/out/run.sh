#!/usr/bin/env bash
set -e

cd /app

# Configure OpenBLAS with the same parameters as the CI job
mkdir -p build
cd build

build_type=Release
c_compiler=gcc
cxx_compiler=g++
dynamic_arch=ON
use_openmp=ON
cpp_thread_safety_use_openmp=ON
dgemm_args="512;12;4"
dgemm_mixed_args="524288;16;20"
dgemv_args="512;12;4"

cmake -G Ninja \
  "-DCMAKE_BUILD_TYPE=$build_type" \
  "-DCMAKE_C_COMPILER=$c_compiler" \
  "-DCMAKE_CXX_COMPILER=$cxx_compiler" \
  -DBUILD_SHARED_LIBS=ON \
  -DBUILD_STATIC_LIBS=OFF \
  -DBUILD_WITHOUT_LAPACK=ON \
  -DBUILD_SINGLE=OFF \
  -DBUILD_DOUBLE=ON \
  -DBUILD_COMPLEX=OFF \
  -DBUILD_COMPLEX16=OFF \
  "-DDYNAMIC_ARCH=$dynamic_arch" \
  -DNOFORTRAN=ON \
  -DUSE_THREAD=ON \
  "-DUSE_OPENMP=$use_openmp" \
  -DNUM_THREADS=32 \
  -DNUM_PARALLEL=2 \
  -DTARGET=CORE2 \
  -DCPP_THREAD_SAFETY_TEST=ON \
  "-DCPP_THREAD_SAFETY_USE_OPENMP=$cpp_thread_safety_use_openmp" \
  "-DCPP_THREAD_SAFETY_DGEMM_ARGS=$dgemm_args" \
  "-DCPP_THREAD_SAFETY_DGEMM_MIXED_ARGS=$dgemm_mixed_args" \
  "-DCPP_THREAD_SAFETY_DGEMV_ARGS=$dgemv_args" \
  -DCMAKE_C_COMPILER_LAUNCHER=ccache \
  -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
  ..

# Build OpenBLAS
cmake --build . --target dgemm_thread_safety dgemm_thread_safety_mixed dgemv_thread_safety

# Show ccache status
ccache -s || true

# Run thread stress tests
export OMP_NUM_THREADS=16
export OPENBLAS_NUM_THREADS=8
ctest -R 'dgemm_thread_safety|dgemm_thread_safety_mixed|dgemv_thread_safety' --output-on-failure

echo "FINAL_STATUS = SUCCESS"
