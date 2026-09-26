#!/bin/bash

set -e

# Clone the repository (if needed) or assume it's already copied
# git clone <repository-url> .
# git checkout <branch> && git reset --hard <commit-sha>

# Install project dependencies
# Already handled in Dockerfile

# Configure with arm-linux-gnueabi-gcc-14
set -x
autoreconf -i
mkdir build
cd build
../configure --build=$(../config/config.guess) \
             --host=arm-linux-gnueabi \
             --with-testdriver="$(pwd)/libtool execute $(pwd)/../scripts/qemu-test-driver" \
             --enable-debug --enable-coredump

# Build the project
make -j$(nproc)

# ABI Check
srcdir=$(pwd)
cd build/tests
./check-namespace.sh

# Run tests
set -x
bash -c 'echo core.%p.%p > /proc/sys/kernel/core_pattern'
ulimit -c unlimited
cd ../
make check -j$(nproc) LOG_DRIVER_FLAGS="--qemu-arch arm" \
           QEMU_LD_PREFIX="/usr/arm-linux-gnueabi" \
           LDFLAGS="-L/usr/arm-linux-gnueabi/lib"