#!/bin/bash
set -e

# Set environment variables
export APR_VERSION=1.7.4
export APU_VERSION=1.6.3
export APU_CONFIG="--with-crypto"
export NO_TEST_FRAMEWORK=1
export TEST_INSTALL=1
export TEST_H2=1
export TEST_CORE=1
export TEST_PROXY=1
export CONFIG="--enable-mods-shared=reallyall --with-mpm=event --enable-mpms-shared=all"
export MARGS="-j2"
export CFLAGS="-g"
export PHP_FPM="/usr/sbin/php-fpm8.1"

# Note: sysctl vm.mmap_rnd_bits=28 is handled in GitHub Actions workflow
# and cannot be set in Docker containers without --privileged flag

# Configure environment
echo "Running configure environment script..."

# Create a wrapper script that skips /etc/hosts modification for Docker
# The travis_before_linux.sh script tries to modify /etc/hosts which fails in Docker
# We'll patch it to skip that operation
if [ -f ./test/travis_before_linux.sh ]; then
    # Create a temporary patched version that skips the /etc/hosts modification
    sed '/sudo sed -i \/ip6-\/d \/etc\/hosts/d' ./test/travis_before_linux.sh > /tmp/travis_before_linux_patched.sh
    chmod +x /tmp/travis_before_linux_patched.sh
    /tmp/travis_before_linux_patched.sh
else
    echo "Warning: travis_before_linux.sh not found"
fi

# Build and test
echo "Running build and test script..."
./test/travis_run_linux.sh

echo "Build and test completed successfully!"