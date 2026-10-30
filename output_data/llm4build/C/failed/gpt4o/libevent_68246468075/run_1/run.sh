#!/bin/bash

# Set CMake options
EVENT_CMAKE_OPTIONS="-DEVENT__DISABLE_THREAD_SUPPORT=ON"

# Build the project
mkdir -p build
cd build
echo [cmake]: cmake .. $EVENT_CMAKE_OPTIONS
cmake .. $EVENT_CMAKE_OPTIONS || (rm -rf * && cmake .. $EVENT_CMAKE_OPTIONS)
cmake --build .

# Run tests
JOBS=1
export CTEST_PARALLEL_LEVEL=$JOBS
export CTEST_OUTPUT_ON_FAILURE=1
cmake --build . --target verify