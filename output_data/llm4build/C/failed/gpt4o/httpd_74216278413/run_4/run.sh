#!/bin/bash

# Set environment variables
export APR_VERSION=1.7.4
export APU_VERSION=1.6.3
export APU_CONFIG="--with-crypto"
export NO_TEST_FRAMEWORK=1
export TEST_INSTALL=1
export TEST_H2=1
export TEST_CORE=1
export TEST_PROXY=1

# Workaround ASAN issue in Ubuntu 22.04
sysctl vm.mmap_rnd_bits=28 || echo "Skipping sysctl adjustment"

# Ensure APR and APU are correctly configured
APR_PREFIX="/usr"
APU_PREFIX="/usr"

# Download and build APR and APU if not already installed
if [ ! -f "$APR_PREFIX/bin/apr-1-config" ]; then
    curl -O https://downloads.apache.org/apr/apr-$APR_VERSION.tar.gz
    tar -xzf apr-$APR_VERSION.tar.gz
    cd apr-$APR_VERSION
    ./configure --prefix=$APR_PREFIX
    make
    make install
    cd ..
fi

if [ ! -f "$APU_PREFIX/bin/apu-1-config" ]; then
    curl -O https://downloads.apache.org/apr/apr-util-$APU_VERSION.tar.gz
    tar -xzf apr-util-$APU_VERSION.tar.gz
    cd apr-util-$APU_VERSION
    ./configure --prefix=$APU_PREFIX --with-apr=$APR_PREFIX $APU_CONFIG
    make
    make install
    cd ..
fi

# Run autoupdate to update obsolete macros
autoupdate || echo "Autoupdate failed, continuing with existing macros"

# Configure environment
./test/travis_before_linux.sh

# Build and test
./test/travis_run_linux.sh --with-apr=$APR_PREFIX --with-apr-util=$APU_PREFIX