#!/bin/bash

# Clone the repository and update submodules
git clone --recurse-submodules <actual-repository-url> .
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