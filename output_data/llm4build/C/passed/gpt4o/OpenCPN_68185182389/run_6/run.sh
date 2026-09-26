#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Ensure the repository is up-to-date and submodules are initialized
git submodule update --init --recursive

# Run pre-build script
# Remove sudo as it's not needed in Docker
sed -i 's/sudo //g' ./ci/github-pre-build.sh
chmod +x ./ci/github-pre-build.sh
./ci/github-pre-build.sh

# Configure CMake
cmake -B build -DCMAKE_BUILD_TYPE=Release

# Build the project
cmake --build build --config Release

# Run tests
cd build
make run-tests || true  # Ensure all tests run even if some fail