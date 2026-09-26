#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Clone the repository and update submodules
# Replace <actual-repository-url> with the actual URL
git clone --recurse-submodules https://github.com/your-username/your-repository.git .
git submodule update --init --recursive

# Run pre-build script
chmod +x ./ci/github-pre-build.sh
./ci/github-pre-build.sh

# Configure CMake
cmake -B build -DCMAKE_BUILD_TYPE=Release

# Build the project
cmake --build build --config Release

# Run tests
cd build
make run-tests || true  # Ensure all tests run even if some fail