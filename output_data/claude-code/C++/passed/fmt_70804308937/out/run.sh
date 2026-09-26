#!/usr/bin/env bash
set -e

cd /build

export CXX=clang++-11
export CXXFLAGS=""

echo "=== Configure ==="
cmake -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_CXX_STANDARD=11 \
      -DCMAKE_CXX_VISIBILITY_PRESET=hidden \
      -DCMAKE_VISIBILITY_INLINES_HIDDEN=ON \
      -DFMT_DOC=OFF -DFMT_PEDANTIC=ON \
      -DFMT_WERROR=ON \
      /app

echo "=== Build ==="
threads=$(nproc)
cmake --build . --config Release --parallel $threads

echo "=== Test ==="
export CTEST_OUTPUT_ON_FAILURE=True
ctest -C Release

echo "FINAL_STATUS = SUCCESS"
