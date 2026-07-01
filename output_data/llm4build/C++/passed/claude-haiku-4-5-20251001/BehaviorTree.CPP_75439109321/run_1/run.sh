#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Create Conan default profile
conan profile detect

# Install Conan dependencies
conan install conanfile.py -s build_type=${BUILD_TYPE} --build=missing -of build/${BUILD_TYPE}

# Normalize build type to lowercase
BUILD_TYPE_LOWERCASE=$(echo "${BUILD_TYPE}" | tr '[:upper:]' '[:lower:]')

# Configure CMake using the generated toolchain file directly
# This avoids preset version compatibility issues
cmake -B build/${BUILD_TYPE} \
    -G "Unix Makefiles" \
    -DCMAKE_TOOLCHAIN_FILE=build/${BUILD_TYPE}/generators/conan_toolchain.cmake \
    -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
    -DUSE_VENDORED_CPPZMQ=OFF \
    -DUSE_VENDORED_FLATBUFFERS=OFF \
    -DUSE_VENDORED_LEXY=OFF \
    -DUSE_VENDORED_MINICORO=OFF \
    -DUSE_VENDORED_MINITRACE=OFF \
    -DUSE_VENDORED_TINYXML2=OFF \
    -DCMAKE_POLICY_DEFAULT_CMP0091=NEW

# Build
cmake --build build/${BUILD_TYPE}

# Run tests
ctest --test-dir build/${BUILD_TYPE} --output-on-failure