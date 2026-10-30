#!/bin/bash
set -e

# Enable core dumps (ulimit only, skip /proc write which may be read-only in containers)
ulimit -c unlimited

# Set cross-compiler environment variables
export CC=arm-linux-gnueabi-gcc-14
export CXX=arm-linux-gnueabi-g++-14
export CFLAGS="-Wall -Wextra -g -Og -fstrict-aliasing -Wstrict-aliasing -Werror=strict-aliasing"

# Configure the project
echo "=== Configuring libunwind ==="
autoreconf -i
mkdir -p build
cd build

../configure --build=$(../config/config.guess) \
             --host=arm-linux-gnueabi \
             --with-testdriver="$(pwd)/libtool execute $(pwd)/../scripts/qemu-test-driver" \
             --enable-debug --enable-coredump

# Build the project
echo "=== Building libunwind ==="
make -j$(nproc)

# ABI Check
echo "=== Running ABI Check ==="
srcdir=$(pwd)
cd tests
./check-namespace.sh
cd ..

# Run tests
echo "=== Running Tests ==="
make check -j$(nproc) \
    LOG_DRIVER_FLAGS="--qemu-arch arm" \
    QEMU_LD_PREFIX="/usr/arm-linux-gnueabi" \
    LDFLAGS="-L/usr/arm-linux-gnueabi/lib" \
    UNW_DEBUG_LEVEL=4

echo "=== All tests completed ==="