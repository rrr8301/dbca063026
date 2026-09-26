#!/bin/bash

# Activate environment variables if needed
export CHERE_INVOKING=1

# Install project dependencies
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_SHARED_LIBS=ON \
      -DBUILD_STATIC_LIBS=ON \
      -DDYNAMIC_ARCH=ON \
      -DUSE_THREAD=ON \
      -DNUM_THREADS=64 \
      -DTARGET=CORE2 \
      -DCMAKE_C_COMPILER_LAUNCHER=ccache \
      -DCMAKE_Fortran_COMPILER_LAUNCHER=ccache \
      ..

# Build the project
cmake --build .

# Run tests
ctest || true

# Re-run failed tests
ctest --rerun-failed --output-on-failure || true