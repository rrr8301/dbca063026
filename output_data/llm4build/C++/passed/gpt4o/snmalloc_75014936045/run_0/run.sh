#!/bin/bash

# Configure CMake
cmake -B /app/build -DCMAKE_BUILD_TYPE=Debug -G Ninja

# Build the project
cmake --build /app/build

# Run tests
ctest --output-on-failure -j 4 -C Debug --timeout 400