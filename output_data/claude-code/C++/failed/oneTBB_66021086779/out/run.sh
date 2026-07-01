#!/usr/bin/env bash
set -x

cd /app
mkdir build && cd build

cmake -DCMAKE_CXX_STANDARD=14 -DCMAKE_BUILD_TYPE=relwithdebinfo \
  -DCMAKE_CXX_COMPILER=g++ -DCMAKE_C_COMPILER=gcc -DTBB_CPF=OFF ..

make VERBOSE=1 -j2

ctest --timeout 180 --output-on-failure

echo "FINAL_STATUS = SUCCESS"
