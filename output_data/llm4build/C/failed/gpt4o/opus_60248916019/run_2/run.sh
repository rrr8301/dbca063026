#!/bin/bash

# Clone the repository (simulating actions/checkout)
git clone --depth=1 https://github.com/example/repository.git .  # Replace with actual repository URL

# Ensure autogen.sh is executable
chmod +x autogen.sh

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