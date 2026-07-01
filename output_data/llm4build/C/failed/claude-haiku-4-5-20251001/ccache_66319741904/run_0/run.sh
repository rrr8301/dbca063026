#!/bin/bash

set -e

# Set CMAKE_PARAMS based on ubuntu-22.04 logic
cmake_params=(-D CMAKE_BUILD_TYPE=CI)
cmake_params+=(-D DEPS=LOCAL)
export CMAKE_PARAMS="${cmake_params[*]}"

# Build and test
ci/build

# Collect testdir from failed tests if build failed
if [ $? -ne 0 ]; then
    ci/collect-testdir || true
    exit 1
fi

exit 0