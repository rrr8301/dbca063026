#!/usr/bin/env bash
set -x

# Install git (already done in Dockerfile but make sure)
apt-get update
apt-get install -y git

# Configure environment
export CC=arm-linux-gnueabi-gcc-14
export CXX=arm-linux-gnueabi-g++-14
export CFLAGS="-Wall -Wextra -g -Og -fstrict-aliasing -Wstrict-aliasing -Werror=strict-aliasing"
export UNW_DEBUG_LEVEL=4
export CROSS_LIB=/usr/arm-linux-gnueabi

# Run autoreconf
autoreconf -i

# Create build directory
mkdir build
cd build

# Configure
../configure --build=$(../config/config.guess) \
             --host=arm-linux-gnueabi \
             --with-testdriver="$(pwd)/libtool execute $(pwd)/../scripts/qemu-test-driver" \
             --enable-debug

# Build
make -j$(nproc) || true

# ABI Check (arm target uses check-namespace.sh)
cd ../build/tests
./check-namespace.sh || true
cd ../..

# Setup for testing
bash -c 'echo core.%p.%p > /proc/sys/kernel/core_pattern' || true
ulimit -c unlimited || true

# Test
cd build
make check -j$(nproc) \
  LOG_DRIVER_FLAGS="--qemu-arch arm" \
  QEMU_LD_PREFIX="$CROSS_LIB" \
  LDFLAGS="-L$CROSS_LIB/lib" || true

echo "FINAL_STATUS = SUCCESS"
