#!/bin/bash

set -e

# Print system information
echo "=== System Information ==="
cat /proc/cpuinfo || true

# Configure ccache
echo "=== Configuring ccache ==="
mkdir -p ~/.ccache
echo "max_size = 300M" > ~/.ccache/ccache.conf
echo "compression = true" >> ~/.ccache/ccache.conf
ccache -s

# Build OpenBLAS
echo "=== Building OpenBLAS ==="
mkdir -p build
cd build

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
echo "=== ccache Status ==="
ccache -s || true

# Run tests
echo "=== Running Tests ==="
timeout 3600 ctest --output-on-failure || TEST_FAILED=1

# Exit with appropriate code
if [ "${TEST_FAILED}" = "1" ]; then
    echo "Tests completed with failures"
    exit 1
fi

echo "=== Build and Tests Completed Successfully ==="
exit 0