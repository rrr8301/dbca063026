#!/bin/bash

# Navigate to the source directory if needed
cd /workspace

# Run CMake to configure the project
cmake -S . -B build

# Build the project
cmake --build build

# Run tests
ctest --test-dir build