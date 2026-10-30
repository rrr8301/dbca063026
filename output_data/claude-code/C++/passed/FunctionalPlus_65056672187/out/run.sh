#!/usr/bin/env bash

set -e

INSTALL_PREFIX="$HOME/.local"
export CMAKE_PREFIX_PATH=$INSTALL_PREFIX:$CMAKE_PREFIX_PATH

# Install doctest
cd /app
git clone --depth=1 --branch=v2.5.0 https://github.com/doctest/doctest
cd doctest && mkdir -p build && cd build
cmake .. -DDOCTEST_WITH_TESTS=OFF -DDOCTEST_WITH_MAIN_IN_STATIC_LIB=OFF -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX
cmake --build . --config Release --target install

# Build
cd /app
JOBS=4
BUILD_TYPE=Release
cmake -S test -B build -D CMAKE_BUILD_TYPE=${BUILD_TYPE}
cmake --build build --config ${BUILD_TYPE} -j ${JOBS}

# Test
cd /app/build
JOBS=4
BUILD_TYPE=Release
ctest -C ${BUILD_TYPE} -j ${JOBS} --output-on-failure

echo "FINAL_STATUS = SUCCESS"
