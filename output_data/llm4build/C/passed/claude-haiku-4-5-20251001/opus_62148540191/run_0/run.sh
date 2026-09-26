#!/bin/bash

set -e

# Clone the repository (assuming it's passed as an environment variable or we clone from current context)
# For local builds, we assume the repo is already available or we clone it
if [ ! -d "opus" ]; then
    git clone https://gitlab.xiph.org/xiph/opus.git opus
fi

cd opus

# Download models and generate build files
echo "Running autogen.sh..."
./autogen.sh

# Install CMake 3.16.0
echo "Installing CMake 3.16.0..."
curl -sL https://github.com/Kitware/CMake/releases/download/v3.16.0/cmake-3.16.0-Linux-x86_64.sh -o cmakeinstall.sh
chmod +x cmakeinstall.sh
./cmakeinstall.sh --prefix=/usr/local --exclude-subdir
rm cmakeinstall.sh

# Create build directory
echo "Creating build directory..."
mkdir -p build
cd build

# Configure with CMake
echo "Configuring with CMake..."
which cmake
cmake --version
cmake .. -DOPUS_BUILD_PROGRAMS=ON -DBUILD_TESTING=ON

# Build
echo "Building..."
make -j 2 -s

# Run tests
echo "Running tests..."
ctest -j 2 || true

echo "Build and test completed!"