#!/usr/bin/env bash
set -e

# Set timezone
timedatectl set-timezone 'Europe/Kyiv' || true

# Create build directory
mkdir -p /build

# Configure
cd /build
export CXX=clang++-14
export CXXFLAGS="-fsanitize=address -fno-sanitize-recover=all -fno-omit-frame-pointer"

cmake -DCMAKE_BUILD_TYPE=Debug \
       -DCMAKE_CXX_STANDARD=20 \
       -DCMAKE_CXX_VISIBILITY_PRESET=hidden \
       -DCMAKE_VISIBILITY_INLINES_HIDDEN=ON \
       -DFMT_DOC=OFF -DFMT_PEDANTIC=ON \
       -DFMT_WERROR=ON \
       /app

# Build
threads=$(nproc)
cmake --build . --config Debug --parallel "$threads"

# Test
export CTEST_OUTPUT_ON_FAILURE=True
ctest -C Debug

echo "FINAL_STATUS = SUCCESS"
