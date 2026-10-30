#!/bin/bash

# Navigate to the source directory if needed
cd /workspace

# Run CMake to configure the project
cmake -S . -B build -G Ninja  # Use Ninja as the generator

# Build the project
cmake --build build

# Run tests
ctest --test-dir build