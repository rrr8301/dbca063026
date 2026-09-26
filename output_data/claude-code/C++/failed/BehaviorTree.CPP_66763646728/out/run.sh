#!/usr/bin/env bash
set -e

export BUILD_TYPE=Release

# Create default profile
conan profile detect

# Install conan dependencies
conan install conanfile.py -s build_type=$BUILD_TYPE --build=missing

# Normalize build type to lowercase
BUILD_TYPE_LOWERCASE=$(echo "${BUILD_TYPE}" | tr '[:upper:]' '[:lower:]')

# Configure CMake
cmake --preset conan-$BUILD_TYPE_LOWERCASE

# Build
cmake --build --preset conan-$BUILD_TYPE_LOWERCASE

# Run tests
ctest --test-dir build/$BUILD_TYPE

echo "FINAL_STATUS = SUCCESS"
