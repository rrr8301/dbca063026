#!/bin/sh

# Ensure the script exits on any error
set -e

# Configure the build
cmake -B build -DBUILD_TESTING=ON

# Build the project
cmake --build build

# Run tests
cd build && ctest -V --output-on-failure