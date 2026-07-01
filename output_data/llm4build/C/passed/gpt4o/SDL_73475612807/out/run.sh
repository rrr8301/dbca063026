#!/bin/bash

# Navigate to the build directory
cd /workspace

# Run your build or test commands here
echo "Running application or tests..."

# Example build and test commands
cmake -S . -B build -G Ninja
cmake --build build
ctest --test-dir build/ -VV -j2

# Replace the following line with the actual command to run your application or tests
# ./your_application_or_test_command