#!/bin/bash

# Clone the repository (if needed, otherwise assume it's copied)
# git clone <repository-url> .
# git checkout <branch>
# git reset --hard <commit-sha>

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
ctest --test-dir build/Release