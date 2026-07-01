#!/bin/bash

set -e

# Configure with arm-linux-gnueabi-gcc-10
autoreconf -i
mkdir -p build
cd build
../configure --build=$(../config/config.guess) \
             --host=arm-linux-gnueabi \
             --with-testdriver="$(pwd)/libtool execute $(pwd)/../scripts/qemu-test-driver" \
             --enable-debug --enable-coredump \
             CC=arm-linux-gnueabi-gcc-10 \
             CXX=arm-linux-gnueabi-g++-10 \
             CFLAGS="-I/usr/include/libunwind"

# Build
make -j$(nproc)

# ABI Check
cd tests
./check-namespace.sh
cd ..

# Test
# Skip setting core_pattern as it requires root and is not necessary for the tests
ulimit -c unlimited
make check -j$(nproc) LOG_DRIVER_FLAGS="--qemu-arch arm" \
           QEMU_LD_PREFIX="/usr/arm-linux-gnueabi" \
           LDFLAGS="-L/usr/arm-linux-gnueabi/lib"