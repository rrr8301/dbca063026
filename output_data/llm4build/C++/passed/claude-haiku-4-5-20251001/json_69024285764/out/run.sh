#!/bin/bash

set -e

# Clone the repository if not already present
if [ ! -d "/workspace/repo" ]; then
    git clone https://github.com/nlohmann/json.git /workspace/repo
fi

cd /workspace/repo

# Download and install CMake and Ninja
echo "Installing CMake and Ninja..."
CMAKE_VERSION="3.28.0"
NINJA_VERSION="1.11.1"

# Download CMake
curl -L https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz -o /tmp/cmake.tar.gz
tar -xzf /tmp/cmake.tar.gz -C /usr/local --strip-components=1
rm /tmp/cmake.tar.gz

# Download Ninja
curl -L https://github.com/ninja-build/ninja/releases/download/v${NINJA_VERSION}/ninja-linux.zip -o /tmp/ninja.zip
unzip /tmp/ninja.zip -d /usr/local/bin
chmod +x /usr/local/bin/ninja
rm /tmp/ninja.zip

# Verify installations
cmake --version
ninja --version

# Configure the project with CMake
echo "Configuring CMake..."
cmake -S . -B build -DJSON_CI=On

# Build the project with the ci_test_gcc target
echo "Building with ci_test_gcc target..."
cmake --build build --target ci_test_gcc

echo "Build and tests completed successfully!"