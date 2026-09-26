#!/bin/bash

# Activate environment (if any specific activation is needed, add here)

# Prepare build
mkdir -p build

# Set up build environment
# Remove sysctl as it is not applicable in Docker
# sysctl vm.mmap_rnd_bits=28 || true  # Removed as it causes issues in Docker

# Source the setup script
if [ -f ci/setup-sanitizer-build.sh ]; then
    # Remove sudo as it is not needed in Docker
    sed -i '/sudo sysctl/d' ci/setup-sanitizer-build.sh
    source ci/setup-sanitizer-build.sh
else
    echo "Setup script not found, skipping..."
fi

# Build the project
cd build
cmake .. -DCMAKE_BUILD_TYPE=Debug -G Ninja -DUSE_HTTPS=OpenSSL  # Specify OpenSSL as the HTTPS backend
ninja

# Run tests
set +e  # Ensure all tests run even if some fail
if [ -f ../ci/test.sh ]; then
    ../ci/test.sh
else
    echo "Test script not found, skipping..."
fi