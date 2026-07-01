#!/usr/bin/env bash
set -e

cd /app

echo "Running autogen.sh..."
./autogen.sh

echo "Installing CMake 3.16.0..."
curl -sL https://github.com/Kitware/CMake/releases/download/v3.16.0/cmake-3.16.0-Linux-x86_64.sh -o cmakeinstall.sh
chmod +x cmakeinstall.sh
./cmakeinstall.sh --prefix=/usr/local --exclude-subdir
rm cmakeinstall.sh

echo "Creating build directory..."
mkdir build
cd build

echo "Checking CMake..."
which cmake
cmake --version

echo "Configuring..."
cmake .. -DOPUS_BUILD_PROGRAMS=ON -DBUILD_TESTING=ON

echo "Building..."
make -j 2 -s

echo "Running tests..."
ctest -j 2

echo "FINAL_STATUS = SUCCESS"
