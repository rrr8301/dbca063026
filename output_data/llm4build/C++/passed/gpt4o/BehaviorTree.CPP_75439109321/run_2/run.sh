#!/bin/bash

# Create default Conan profile
conan profile detect

# Install Conan dependencies
conan install conanfile.py -s build_type=Release --build=missing

# Normalize build type
BUILD_TYPE_LOWERCASE=$(echo "Release" | tr '[:upper:]' '[:lower:]')

# Configure CMake
cmake --preset conan-${BUILD_TYPE_LOWERCASE}

# Build with CMake
cmake --build --preset conan-${BUILD_TYPE_LOWERCASE}

# Run tests
# Ensure the correct path to the test directory
ctest --test-dir build/${BUILD_TYPE_LOWERCASE}