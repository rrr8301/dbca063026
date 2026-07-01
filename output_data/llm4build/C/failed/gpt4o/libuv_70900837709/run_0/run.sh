#!/bin/bash

# Clone the repository (simulated by copying in Dockerfile)
# git clone <repo-url> /app

# Install project dependencies (already handled in Dockerfile)

# Configure the build
cmake -B build -DBUILD_TESTING=ON

# Build the project
cmake --build build

# Run tests
cd build && ctest -V --output-on-failure