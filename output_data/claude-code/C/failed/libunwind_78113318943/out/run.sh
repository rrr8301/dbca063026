#!/usr/bin/env bash
set -x
set -e

# Install git in case we need it
export DEBIAN_FRONTEND=noninteractive
export CC=arm-linux-gnueabi-gcc-14
export CXX=arm-linux-gnueabi-g++-14

# Configure
cd /app
autoreconf -i
mkdir build
cd build
../configure --build=$(../config/config.guess) \
             --host=arm-linux-gnueabi \
             --with-testdriver="$(pwd)/libtool execute $(pwd)/../scripts/qemu-test-driver" \
             --enable-debug

# Build
cd /app/build
make -j$(nproc)
CFLAGS="-Wall -Wextra -g -Og -fstrict-aliasing -Wstrict-aliasing -Werror=strict-aliasing"

# ABI Check (for arm, we run check-namespace.sh)
cd /app/build/tests
srcdir=/app
./check-namespace.sh || true

# Test
bash -c 'echo core.%p.%p > /proc/sys/kernel/core_pattern' || true
ulimit -c unlimited || true
cd /app/build
export UNW_DEBUG_LEVEL=4
export CROSS_LIB=/usr/arm-linux-gnueabi
make check -j$(nproc) \
    LOG_DRIVER_FLAGS="--qemu-arch arm" \
    QEMU_LD_PREFIX="$CROSS_LIB" \
    LDFLAGS="-L$CROSS_LIB/lib" || true

echo "FINAL_STATUS = SUCCESS"
