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

# Ensure APR and APU are correctly configured
APR_PREFIX="/usr/local/apr"
APU_PREFIX="/usr/local/apr-util"

# Download and build APR and APU if not already installed
if [ ! -f "$APR_PREFIX/bin/apr-1-config" ]; then
    curl -O https://downloads.apache.org/apr/apr-$APR_VERSION.tar.bz2
    if [ $? -ne 0 ]; then
        echo "Failed to download APR. Exiting."
        exit 1
    fi
    tar -xjf apr-$APR_VERSION.tar.bz2 || { echo "Failed to extract APR. Exiting."; exit 1; }
    cd apr-$APR_VERSION || { echo "Failed to enter APR directory. Exiting."; exit 1; }
    ./configure --prefix=$APR_PREFIX
    make
    make install
    cd ..
fi

if [ ! -f "$APU_PREFIX/bin/apu-1-config" ]; then
    curl -O https://downloads.apache.org/apr/apr-util-$APU_VERSION.tar.bz2
    if [ $? -ne 0 ]; then
        echo "Failed to download APU. Exiting."
        exit 1
    fi
    tar -xjf apr-util-$APU_VERSION.tar.bz2 || { echo "Failed to extract APU. Exiting."; exit 1; }
    cd apr-util-$APU_VERSION || { echo "Failed to enter APU directory. Exiting."; exit 1; }
    ./configure --prefix=$APU_PREFIX --with-apr=$APR_PREFIX $APU_CONFIG
    make
    make install
    cd ..
fi

# Configure environment
if [ -f "./test/travis_before_linux.sh" ]; then
    ./test/travis_before_linux.sh
else
    echo "travis_before_linux.sh not found, skipping"
fi

# Build and test
if [ -f "./test/travis_run_linux.sh" ]; then
    ./test/travis_run_linux.sh --with-apr=$APR_PREFIX --with-apr-util=$APU_PREFIX
else
    echo "travis_run_linux.sh not found, skipping"
fi