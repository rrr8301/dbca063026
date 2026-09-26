#!/bin/bash

# Activate ccache
export CMAKE_C_COMPILER_LAUNCHER=ccache
export CMAKE_CXX_COMPILER_LAUNCHER=ccache

# Configure ccache
ccache -M 500M
ccache -z

# Build the project
./scripts/build-local.sh

# Run tests
cd build/local
ctest --output-on-failure --parallel $(nproc) || true

# Print ccache stats
ccache -s