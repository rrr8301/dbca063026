#!/bin/bash

# Clone the repository (simulating actions/checkout)
# Assuming the repository is already copied in the Dockerfile

# Run CMake
cmake -S . -B build -DJSON_CI=On

# Build the project
cmake --build build --target ci_test_gcc

# Run tests
# Assuming tests are part of the build process
# If there are specific test commands, they should be added here