#!/bin/bash

# Set build type
BUILD_TYPE=Release
BUILD_TYPE_LOWERCASE=$(echo "${BUILD_TYPE}" | tr '[:upper:]' '[:lower:]')

# Create default Conan profile
conan profile detect

# Install Conan dependencies
conan install conanfile.py -s build_type=${BUILD_TYPE} --build=missing

# Configure CMake
cmake --preset conan-${BUILD_TYPE_LOWERCASE}

# Build with CMake
cmake --build --preset conan-${BUILD_TYPE_LOWERCASE}

# Run tests with CTest
ctest --test-dir build/${BUILD_TYPE}