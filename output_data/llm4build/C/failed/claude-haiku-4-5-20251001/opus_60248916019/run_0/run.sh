#!/bin/bash
set -e

# Clone the repository (simulating actions/checkout@v3 with fetch-depth: 0)
if [ ! -d "opus" ]; then
    git clone --fetch-depth=0 https://github.com/xiph/opus.git .
else
    cd opus
fi

# Download models
echo "Downloading models..."
./autogen.sh

# Install CMake 3.16.0
echo "Installing CMake 3.16.0..."
curl -sL https://github.com/Kitware/CMake/releases/download/v3.16.0/cmake-3.16.0-Linux-x86_64.sh -o cmakeinstall.sh
chmod +x cmakeinstall.sh
./cmakeinstall.sh --prefix=/usr/local --exclude-subdir
rm cmakeinstall.sh

# Create build directory
mkdir -p build
cd build

# Configure
echo "Configuring CMake..."
which cmake
cmake --version
cmake .. -DOPUS_BUILD_PROGRAMS=ON -DBUILD_TESTING=ON

# Build
echo "Building..."
make -j 2 -s

# Test
echo "Running tests..."
ctest -j 2

echo "All tests passed!"