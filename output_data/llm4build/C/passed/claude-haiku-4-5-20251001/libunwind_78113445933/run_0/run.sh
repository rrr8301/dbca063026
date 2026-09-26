#!/bin/bash
set -e

# Enable core dumps and set core pattern
echo core.%p.%p > /proc/sys/kernel/core_pattern
ulimit -c unlimited

# Navigate to workspace
cd /workspace

# Configure the project with arm-linux-gnueabi cross-compiler
set -x
autoreconf -i
mkdir -p build
cd build

../configure --build=$(../config/config.guess) \
             --host=arm-linux-gnueabi \
             --with-testdriver="$(pwd)/libtool execute $(pwd)/../scripts/qemu-test-driver" \
             --enable-debug

# Build the project
export CC=arm-linux-gnueabi-gcc-14
export CXX=arm-linux-gnueabi-g++-14
export CFLAGS="-Wall -Wextra -g -Og -fstrict-aliasing -Wstrict-aliasing -Werror=strict-aliasing"

make -j$(nproc)

# ABI Check
srcdir=$(pwd)
cd tests
./check-namespace.sh
cd ..

# Run tests
set -x
export UNW_DEBUG_LEVEL=4
export CROSS_LIB=/usr/arm-linux-gnueabi

make check -j$(nproc) \
    LOG_DRIVER_FLAGS="--qemu-arch arm" \
    QEMU_LD_PREFIX="/usr/arm-linux-gnueabi" \
    LDFLAGS="-L/usr/arm-linux-gnueabi/lib"

echo "All tests completed successfully!"