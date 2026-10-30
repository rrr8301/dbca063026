#!/bin/bash

# Activate environment variables
export CTEST_OUTPUT_ON_FAILURE=ON
export VERBOSE=1
export CMAKE_GENERATOR=Ninja

# Build and test
/workspace/ci/build

# Collect test directory from failed tests
if [ $? -ne 0 ]; then
    /workspace/ci/collect-testdir
fi