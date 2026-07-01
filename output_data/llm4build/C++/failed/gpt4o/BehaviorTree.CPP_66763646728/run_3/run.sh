#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Print each command before executing it (useful for debugging)
set -x

# Install Conan dependencies
conan profile detect
conan install conanfile.py -s build_type=Release --build=missing

# Configure CMake
cmake --preset conan-release

# Build the project
cmake --build --preset conan-release

# Run tests
ctest --test-dir build/Release