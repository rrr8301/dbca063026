#!/bin/bash

# Create default Conan profile
conan profile detect

# Install Conan dependencies
conan install conanfile.py -s build_type=Release --build=missing

# Normalize build type
BUILD_TYPE_LOWERCASE=$(echo "Release" | tr '[:upper:]' '[:lower:]')

# Create build directory
mkdir -p build/${BUILD_TYPE_LOWERCASE}

# Change to build directory
cd build/${BUILD_TYPE_LOWERCASE}

# Configure CMake
cmake --preset conan-${BUILD_TYPE_LOWERCASE} ../..

# Build with CMake
cmake --build .

# Run tests
ctest