#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Clone the repository (assuming the repository URL is provided as an argument)
# git clone <repository-url> .

# Run CMake to configure the project
cmake -S . -B build -DJSON_CI=On

# Build the project using CMake
cmake --build build --target ci_test_gcc

# Run tests (if any)
# Assuming tests are part of the build target, otherwise specify the test command
# ctest --test-dir build

# Ensure all test cases are executed, even if some fail
# (Uncomment the above line if tests are part of the build process)