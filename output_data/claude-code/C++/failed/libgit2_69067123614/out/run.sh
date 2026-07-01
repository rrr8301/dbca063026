#!/usr/bin/env bash

set -e

# Prepare build directory
mkdir -p build
cd build

# Run the setup script (disable ASLR for TSAN compatibility)
sysctl -w vm.mmap_rnd_bits=28 || true

# Build libgit2
echo "Building libgit2..."
../ci/build.sh

# Run tests
echo "Running tests..."
../ci/test.sh

# If we reach here, tests ran successfully
echo ""
echo "##############################################################################"
echo "Tests completed"
echo "##############################################################################"
echo ""
echo "FINAL_STATUS = SUCCESS"
