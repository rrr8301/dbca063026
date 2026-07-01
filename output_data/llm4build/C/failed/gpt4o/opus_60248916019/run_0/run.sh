#!/bin/bash

# Clone the repository (simulating actions/checkout)
git clone --depth=1 <repository-url> .

# Run autogen.sh to download models
./autogen.sh

# Create build directory
mkdir -p build

# Configure the build
cd build
cmake .. -DOPUS_BUILD_PROGRAMS=ON -DBUILD_TESTING=ON

# Build the project
make -j 2 -s

# Test the build
ctest -j 2