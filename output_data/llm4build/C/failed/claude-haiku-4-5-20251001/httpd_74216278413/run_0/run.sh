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
sudo sysctl vm.mmap_rnd_bits=28 || true

# Configure environment (build dependencies)
echo "Configuring environment..."
./test/travis_before_linux.sh

# Build and test
echo "Building and testing..."
./test/travis_run_linux.sh

echo "Build and test completed successfully!"