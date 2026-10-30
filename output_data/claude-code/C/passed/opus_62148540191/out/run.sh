#!/usr/bin/env bash

set -e

cd /app/build

which cmake
cmake --version

cmake .. -DOPUS_BUILD_PROGRAMS=ON -DBUILD_TESTING=ON

make -j 2 -s

ctest -j 2

echo "FINAL_STATUS = SUCCESS"
