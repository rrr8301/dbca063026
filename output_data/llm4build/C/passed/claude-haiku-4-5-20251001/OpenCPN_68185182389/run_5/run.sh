#!/bin/bash

set -e

# Navigate to workspace
cd /workspace

# Set non-interactive mode for apt-get
export DEBIAN_FRONTEND=noninteractive
export DEBIAN_PRIORITY=critical
export DEBCONF_NOWARNINGS=yes
export APT_LISTCHANGES_FRONTEND=none

# Configure apt to not ask for confirmation
echo 'APT::Get::Assume-Yes "true";' | sudo tee /etc/apt/apt.conf.d/90assumeyes > /dev/null
echo 'APT::Get::AutoRemove "true";' | sudo tee -a /etc/apt/apt.conf.d/90assumeyes > /dev/null

# Run pre-build script to install any additional dependencies
echo "Running pre-build setup..."
./ci/github-pre-build.sh

# Configure CMake with Release build type
echo "Configuring CMake..."
cmake -B build -DCMAKE_BUILD_TYPE=Release

# Build the project
echo "Building project..."
cmake --build build --config Release

# Run tests (continue on error to ensure all tests run)
echo "Running tests..."
cd build
export CTEST_OUTPUT_ON_FAILURE=1
make run-tests || true

echo "Build and test complete."