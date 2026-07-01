#!/bin/bash
set -e

# Set environment variables for build
export BS=autotools
export MAKE_ARGS=-j4
export CTEST_OUTPUT_ON_FAILURE=ON
export SKIP_OPEN_FD_ERR_TEST=1

# Autogen
echo "=== Running autogen ==="
./build/ci/build.sh -a autogen

# Configure
echo "=== Running configure ==="
export CRYPTO=mbedtls
./build/ci/build.sh -a configure

# Build
echo "=== Running build ==="
./build/ci/build.sh -a build

# Test
echo "=== Running test ==="
./build/ci/build.sh -a test

# Install
echo "=== Running install ==="
./build/ci/build.sh -a install

# Artifact
echo "=== Running artifact ==="
./build/ci/build.sh -a artifact

echo "=== Build and test completed successfully ==="