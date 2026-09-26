#!/bin/bash

# Generate project files
cmake -S . -B ../build -DMINIZIP_ENABLE_BZIP2=ON -D CMAKE_BUILD_TYPE=Release -DZLIB_BUILD_MINIZIP=ON

# Compile source code
cmake --build ../build --config Release

# Run test cases
ctest -C Release --output-on-failure --max-width 120 --test-dir ../build || true

# Create packages
cmake --build ../build --config Release -t package package_source