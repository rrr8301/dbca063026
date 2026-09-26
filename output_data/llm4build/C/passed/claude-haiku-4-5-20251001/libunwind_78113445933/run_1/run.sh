#!/bin/bash
set -e

# Enable core dumps and set core pattern (gracefully handle if not privileged)
if [ -w /proc/sys/kernel/core_pattern ]; then
    echo core.%p.%p > /proc/sys/kernel/core_pattern
else
    echo "Warning: Cannot write to /proc/sys/kernel/core_pattern (not privileged), continuing anyway"
fi

ulimit -c unlimited || true

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