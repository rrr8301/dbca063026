#!/bin/bash

# Activate environment (if any specific activation is needed, add here)

# Prepare build
mkdir -p build

# Set up build environment
# Remove sysctl as it is not applicable in Docker
# sysctl vm.mmap_rnd_bits=28 || true  # Removed as it causes issues in Docker

# Source the setup script
source ci/setup-sanitizer-build.sh

# Build the project
cd build
cmake .. -DCMAKE_BUILD_TYPE=Debug -G Ninja
ninja

# Run tests
set +e  # Ensure all tests run even if some fail
../ci/test.sh