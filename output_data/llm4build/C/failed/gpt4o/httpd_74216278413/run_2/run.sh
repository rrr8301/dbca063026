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

# Configure environment
./test/travis_before_linux.sh

# Build and test
./test/travis_run_linux.sh --with-apr=$APR_PREFIX --with-apr-util=$APU_PREFIX