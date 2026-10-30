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

# Run the travis_before_linux.sh script to build APR/APU
if [ -f ./test/travis_before_linux.sh ]; then
    echo "Executing travis_before_linux.sh..."
    # Make the script executable and run it
    chmod +x ./test/travis_before_linux.sh
    
    # Run the script, allowing it to fail gracefully for non-critical issues
    # but ensuring APR/APU are built
    bash ./test/travis_before_linux.sh || {
        exit_code=$?
        echo "travis_before_linux.sh exited with code $exit_code"
        # Check if APR was actually built despite the exit code
        if [ ! -d "$HOME/root/apr-$APR_VERSION" ]; then
            echo "ERROR: APR was not built successfully"
            exit $exit_code
        fi
    }
else
    echo "ERROR: travis_before_linux.sh not found"
    exit 1
fi

# Verify APR and APU were built
if [ ! -d "$HOME/root/apr-$APR_VERSION" ]; then
    echo "ERROR: APR directory not found at $HOME/root/apr-$APR_VERSION"
    exit 1
fi

if [ ! -d "$HOME/root/apr-util-$APU_VERSION" ]; then
    echo "ERROR: APU directory not found at $HOME/root/apr-util-$APU_VERSION"
    exit 1
fi

echo "APR and APU built successfully"
echo "APR location: $HOME/root/apr-$APR_VERSION"
echo "APU location: $HOME/root/apr-util-$APU_VERSION"

# Build and test
echo "Running build and test script..."
chmod +x ./test/travis_run_linux.sh
./test/travis_run_linux.sh

echo "Build and test completed successfully!"