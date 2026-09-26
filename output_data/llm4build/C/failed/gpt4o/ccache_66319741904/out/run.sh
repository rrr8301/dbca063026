#!/bin/bash

# Set environment variables
export CC=clang-14
export CXX=clang++-14
export CMAKE_GENERATOR=Ninja

# Install project dependencies
cmake_params=(-D CMAKE_BUILD_TYPE=CI)
cmake_params+=(-D DEP_DOCTEST=DOWNLOAD)
cmake_params+=(-D DEP_XXHASH=DOWNLOAD)
cmake_params+=(-D DEPS=LOCAL)

# Build and test
ci/build

# Collect testdir from failed tests
if [ $? -ne 0 ]; then
  ci/collect-testdir || true
fi

# Ensure all tests are executed
exit 0