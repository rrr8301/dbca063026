#!/bin/bash

# Ensure the working directory is empty
rm -rf /csound/*

# Clone the repository (simulating actions/checkout)
git clone --depth 1 https://github.com/csound/csound.git /csound
cd /csound

# Configure build
mkdir build
cd build
cmake .. -DUSE_MP3=0 -DUSE_DOUBLE=0 -DBUILD_TESTS=1 -DBUILD_STATIC_LIBRARY=1

# Build Csound
make

# Run tests
make test
make csdtests