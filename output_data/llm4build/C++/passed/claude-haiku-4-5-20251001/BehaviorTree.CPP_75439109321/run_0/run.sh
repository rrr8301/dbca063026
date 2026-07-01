#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Create Conan default profile
conan profile detect

# Install Conan dependencies
conan install conanfile.py -s build_type=${BUILD_TYPE} --build=missing

# Normalize build type to lowercase
BUILD_TYPE_LOWERCASE=$(echo "${BUILD_TYPE}" | tr '[:upper:]' '[:lower:]')

# Configure CMake with Conan preset
cmake --preset conan-${BUILD_TYPE_LOWERCASE}

# Build
cmake --build --preset conan-${BUILD_TYPE_LOWERCASE}

# Run tests
ctest --test-dir build/${BUILD_TYPE}