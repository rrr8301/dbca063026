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

# Configure environment
./test/travis_before_linux.sh

# Ensure build scripts are present
if [ ! -f ./configure ]; then
    echo "Error: configure script not found. Please ensure it is generated or present."
    exit 1
fi

# Build and test
./test/travis_run_linux.sh