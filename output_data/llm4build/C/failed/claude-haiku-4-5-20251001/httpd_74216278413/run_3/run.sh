#!/bin/bash

set -e

# Set environment variables from the job
export MARGS="-j2"
export CFLAGS="-g"
export PHP_FPM="/usr/sbin/php-fpm8.1"
export CONFIG="--enable-mods-shared=reallyall --with-mpm=event --enable-mpms-shared=all"
export APR_VERSION="1.7.4"
export APU_VERSION="1.6.3"
export APU_CONFIG="--with-crypto"
export NO_TEST_FRAMEWORK=1
export TEST_INSTALL=1
export TEST_H2=1
export TEST_CORE=1
export TEST_PROXY=1

# Workaround ASAN issue in Ubuntu 22.04
# This may fail in Docker due to read-only filesystem, so we ignore errors
sysctl vm.mmap_rnd_bits=28 || true

# Fix /etc/hosts in Docker environment
# Use sed without -i flag and redirect output to a temp file, then move it
# This avoids "Device or resource busy" errors in Docker
if grep -q ip6-localhost /etc/hosts 2>/dev/null; then
    sed '/ip6-/d' /etc/hosts > /tmp/hosts.tmp && cat /tmp/hosts.tmp > /etc/hosts && rm /tmp/hosts.tmp || true
fi

# Configure environment (build dependencies)
echo "Configuring environment..."
./test/travis_before_linux.sh

# Build and test
echo "Building and testing..."
./test/travis_run_linux.sh

echo "Build and test completed successfully!"