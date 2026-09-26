#!/bin/bash

# Example commands to run tests or build the project
# You should replace these with the actual commands needed for your project

# Navigate to the source directory if needed
cd /workspace

# Run CMake to configure the project
cmake -S . -B build

# Build the project
cmake --build build

# Run tests
ctest --test-dir build