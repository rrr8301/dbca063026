#!/usr/bin/env bash

set -e

cd /app

mkdir -p build
cd build

cmake -DCMAKE_CXX_STANDARD=17 -DCMAKE_BUILD_TYPE=release \
  -DCMAKE_CXX_COMPILER=g++ -DCMAKE_C_COMPILER=gcc -DTBB_CPF=ON ..

make VERBOSE=1 -j2

ctest --timeout 180 --output-on-failure

echo "FINAL_STATUS = SUCCESS"
