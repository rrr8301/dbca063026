#!/bin/bash

# Activate environment (if any)

# Install project dependencies (if any)

# Build the project
mkdir -p build
cd build
cmake .. -DEVENT__ENABLE_GCC_WARNINGS=ON || (rm -rf * && cmake .. -DEVENT__ENABLE_GCC_WARNINGS=ON)
cmake --build .

# Run tests
JOBS=20
export CTEST_PARALLEL_LEVEL=$JOBS
export CTEST_OUTPUT_ON_FAILURE=1

# Run the tests and ensure all tests run even if some fail
cmake --build . --target verify || true