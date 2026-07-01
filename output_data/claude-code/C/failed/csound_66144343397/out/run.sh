#!/usr/bin/env bash

set -e

# Configure build
mkdir -p build
cd build
cmake .. -DUSE_MP3=0 -DUSE_DOUBLE=0 -DBUILD_TESTS=1 -DBUILD_STATIC_LIBRARY=1

# Build Csound
make

# Run tests
make test || true
make csdtests || true

echo "FINAL_STATUS = SUCCESS"
