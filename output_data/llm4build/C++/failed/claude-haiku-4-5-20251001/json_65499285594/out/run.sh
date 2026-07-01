#!/bin/bash

set -e

# Variables
CMAKE_VERSION="3.30.0"
NINJA_VERSION="1.12.1"
CMAKE_URL="https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz"
NINJA_URL="https://github.com/ninja-build/ninja/releases/download/v${NINJA_VERSION}/ninja-linux.zip"

echo "=========================================="
echo "Installing CMake and Ninja"
echo "=========================================="

# Create temporary directory for downloads
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Download and install CMake
echo "Downloading CMake ${CMAKE_VERSION}..."
curl -L -o "$TEMP_DIR/cmake.tar.gz" "$CMAKE_URL"
tar -xzf "$TEMP_DIR/cmake.tar.gz" -C "$TEMP_DIR"
CMAKE_BIN="$TEMP_DIR/cmake-${CMAKE_VERSION}-linux-x86_64/bin"
export PATH="$CMAKE_BIN:$PATH"

# Download and install Ninja
echo "Downloading Ninja ${NINJA_VERSION}..."
apt-get update && apt-get install -y --no-install-recommends unzip && rm -rf /var/lib/apt/lists/*
curl -L -o "$TEMP_DIR/ninja.zip" "$NINJA_URL"
unzip -q "$TEMP_DIR/ninja.zip" -d "$TEMP_DIR"
export PATH="$TEMP_DIR:$PATH"

# Verify installations
echo "Verifying CMake installation..."
cmake --version

echo "Verifying Ninja installation..."
ninja --version

echo "=========================================="
echo "Building project with CMake"
echo "=========================================="

# Configure CMake
echo "Running CMake configuration..."
cmake -S . -B build -DJSON_CI=On

# Build with target ci_test_gcc
echo "Building target ci_test_gcc..."
cmake --build build --target ci_test_gcc

echo "=========================================="
echo "Build completed successfully"
echo "=========================================="