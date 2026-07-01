#!/bin/bash

# Activate environment
set -e

# Fetch test data if not cached
if [ ! -f data/tests/*.db ]; then
    bash scripts/fetch_test_data.sh
fi

# Configure CMake
cmake -B build -DCMAKE_BUILD_TYPE=Release -DPython3_EXECUTABLE=$(which python3) -Dpybind11_DIR=$(python3 -m pybind11 --cmakedir) -DWITH_CERES=ON -DWITH_PYTHON=ON

# Build the project
cmake --build build --config Release

# Run tests
cd build
ctest -C Release --output-on-failure
ctest -C Release --output-on-failure --rerun-failed