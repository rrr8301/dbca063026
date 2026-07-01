#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Configure CMake
cmake -B /app/build -DCMAKE_BUILD_TYPE=Debug -G Ninja

# Build the project
cmake --build /app/build

# Run tests
cd /app/build
ctest --output-on-failure -j 4 -C Debug --timeout 400