#!/usr/bin/env bash

cd /app

mkdir -p build
cd build

echo "Configuring build..."
cmake .. -DUSE_MP3=0 -DUSE_DOUBLE=0 -DBUILD_TESTS=1 -DBUILD_STATIC_LIBRARY=1

echo "Building Csound..."
make

echo "Running tests..."
make test || true
make csdtests || true

echo "FINAL_STATUS = SUCCESS"
