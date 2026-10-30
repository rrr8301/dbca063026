#!/bin/bash

set -e

# Set environment variables
export BS=cmake
export CRYPTO=mbedtls
export MAKE_ARGS=-j4
export SKIP_OPEN_FD_ERR_TEST=1
export CTEST_OUTPUT_ON_FAILURE=ON

# Change to workspace directory
cd /workspace

# Autogen
./build/ci/build.sh -a autogen

# Configure
./build/ci/build.sh -a configure

# Build
./build/ci/build.sh -a build

# Test
./build/ci/build.sh -a test

# Install
./build/ci/build.sh -a install

# Artifact
./build/ci/build.sh -a artifact

echo "All steps completed successfully!"