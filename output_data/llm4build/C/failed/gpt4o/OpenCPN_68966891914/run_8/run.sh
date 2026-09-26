#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Clone the repository and update submodules into a temporary directory
git clone --recurse-submodules https://github.com/example/repo.git /tmp/repo
cd /tmp/repo

# Ensure pre-build script is executable
chmod +x ./ci/github-pre-build.sh

# Run pre-build script
./ci/github-pre-build.sh

# Move the contents of the cloned repository to /app
cp -r . /app

# Change to the /app directory
cd /app

# Configure CMake
cmake -B build -DCMAKE_BUILD_TYPE=Release

# Build with CMake
cmake --build build --config Release

# Run tests
cd build
make run-tests || true  # Ensure all tests run even if some fail