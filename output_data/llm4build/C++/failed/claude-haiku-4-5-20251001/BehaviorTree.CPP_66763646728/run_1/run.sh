#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Create default Conan profile
conan profile detect

# Install Conan dependencies
conan install conanfile.py -s build_type=Release --build=missing

# Normalize build type to lowercase
BUILD_TYPE_LOWERCASE=$(echo "Release" | tr '[:upper:]' '[:lower:]')

# Configure CMake with Conan preset
cmake --preset conan-${BUILD_TYPE_LOWERCASE}

# Build the project
cmake --build --preset conan-${BUILD_TYPE_LOWERCASE}

# Run tests - use the correct test directory
ctest --test-dir build/Release --output-on-failure

echo "All tests completed successfully!"