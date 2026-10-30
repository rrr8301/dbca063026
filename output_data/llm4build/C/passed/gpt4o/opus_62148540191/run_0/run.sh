#!/bin/bash

# Clone the repository
git clone https://gitlab.xiph.org/xiph/opus.git
cd opus

# Download models
./autogen.sh

# Create build directory
mkdir build
cd build

# Configure the build
cmake .. -DOPUS_BUILD_PROGRAMS=ON -DBUILD_TESTING=ON

# Build the project
make -j 2 -s

# Run tests
ctest -j 2 || true  # Ensure all tests run even if some fail