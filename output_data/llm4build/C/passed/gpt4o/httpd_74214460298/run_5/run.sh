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
    echo "Generating configure script..."
    autoreconf -i
    if [ ! -f ./configure ]; then
        echo "Error: configure script not found and could not be generated."
        exit 1
    fi
fi

# Run autoupdate to address obsolete macros
autoupdate

# Rename configure.in to configure.ac if necessary
if [ -f configure.in ]; then
    mv configure.in configure.ac
fi

# Correct the APR and APU paths
APR_PATH="/usr"
APU_PATH="/usr"

# Build and test
./configure --prefix=/root/build/httpd-root --with-apr=$APR_PATH --with-apr-util=$APU_PATH
if [ $? -ne 0 ]; then
    echo "Error: Configuration failed."
    exit 1
fi

# Run the test script
./test/travis_run_linux.sh