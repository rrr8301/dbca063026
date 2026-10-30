#!/bin/bash

# Activate environment variables
export CC=gcc-11
export CXX=g++-11
export CMAKE_GENERATOR=Ninja
export CTEST_OUTPUT_ON_FAILURE=ON
export VERBOSE=1

# Install project dependencies
# Assuming dependencies are already installed via Dockerfile

# Build and test
ci/build

# Collect testdir from failed tests
if [ $? -ne 0 ]; then
  ci/collect-testdir
fi

# Note: Upload step is skipped