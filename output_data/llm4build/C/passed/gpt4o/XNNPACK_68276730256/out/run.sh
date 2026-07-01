#!/bin/bash

# Activate ccache
export CMAKE_C_COMPILER_LAUNCHER=ccache
export CMAKE_CXX_COMPILER_LAUNCHER=ccache

# Configure ccache
ccache -M 500M
ccache -z

# Build the project
./scripts/build-local.sh

# Check if the build was successful before running tests
if [ $? -eq 0 ]; then
  # Run tests
  cd build/local
  ctest --output-on-failure --parallel $(nproc) || true
else
  echo "Build failed, skipping tests."
fi

# Print ccache stats
ccache -s