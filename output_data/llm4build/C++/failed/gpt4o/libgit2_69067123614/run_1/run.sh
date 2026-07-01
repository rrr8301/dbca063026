#!/bin/bash

# Activate environment (if any specific activation is needed, add here)

# Prepare build
mkdir -p build

# Set up build environment
# Remove sudo as the container runs as root
sysctl vm.mmap_rnd_bits=28 || true  # Use || true to prevent failure if sysctl is not available

# Source the setup script
source ci/setup-sanitizer-build.sh

# Build the project
cd build
cmake .. -DCMAKE_BUILD_TYPE=Debug -G Ninja
ninja

# Run tests
set +e  # Ensure all tests run even if some fail
../ci/test.sh