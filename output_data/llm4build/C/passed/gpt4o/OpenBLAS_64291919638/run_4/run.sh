#!/bin/bash

# Print system information
if [ "$(uname)" == "Linux" ]; then
    cat /proc/cpuinfo
else
    echo "Error: Unsupported OS"
    exit 1
fi

# Configure ccache
mkdir -p ~/.ccache
echo "max_size = 300M" > ~/.ccache/ccache.conf
echo "compression = true" >> ~/.ccache/ccache.conf
ccache -s

# Build OpenBLAS
mkdir -p build && cd build
cmake -DDYNAMIC_ARCH=1 \
      -DNOFORTRAN=0 \
      -DBUILD_WITHOUT_LAPACK=0 \
      -DCMAKE_VERBOSE_MAKEFILE=ON \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_C_COMPILER=clang-21 \
      -DCMAKE_Fortran_COMPILER=gfortran \
      -DCMAKE_C_COMPILER_LAUNCHER=ccache \
      -DCMAKE_Fortran_COMPILER_LAUNCHER=ccache \
      ..
cmake --build .

# Show ccache status
ccache -s || true

# Run tests
cd build && ctest --output-on-failure || true