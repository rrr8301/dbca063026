#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Run autogen.sh to generate configure script
./autogen.sh

# Create build directory
mkdir -p build

# Configure the project
cd build
../configure

# Run distcheck to verify distribution
make distcheck