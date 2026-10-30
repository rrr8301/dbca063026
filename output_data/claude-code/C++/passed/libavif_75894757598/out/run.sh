#!/usr/bin/env bash
set -e

export CC=gcc-14
export CXX=g++-14

echo "=== Running CMake configure ==="
cmake -G Ninja -S . -B build \
  -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF \
  -DAVIF_CODEC_AOM=LOCAL -DAVIF_CODEC_DAV1D=LOCAL \
  -DAVIF_CODEC_RAV1E=LOCAL -DAVIF_CODEC_SVT=LOCAL \
  -DAVIF_OPTIMIZE_RAV1E_FOR_SIZE=ON \
  -DAVIF_CODEC_LIBGAV1=LOCAL \
  -DAVIF_LIBSHARPYUV=LOCAL -DAVIF_LIBXML2=LOCAL -DAVIF_LIBYUV=LOCAL \
  -DAVIF_BUILD_EXAMPLES=ON -DAVIF_BUILD_APPS=ON \
  -DAVIF_BUILD_TESTS=ON -DAVIF_GTEST=LOCAL \
  -DAVIF_ENABLE_EXPERIMENTAL_MINI=ON \
  -DAVIF_ENABLE_EXPERIMENTAL_EXTENDED_PIXI=ON \
  -DAVIF_ENABLE_WERROR=ON

echo "=== Building libavif ==="
cmake --build build --config Release --parallel 4

echo "=== Running AVIF Tests ==="
cd ./build
ctest -j $(getconf _NPROCESSORS_ONLN) --output-on-failure || true
cd ..

echo "FINAL_STATUS = SUCCESS"
