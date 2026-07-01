#!/bin/bash
set -e

# Fetch test data
bash scripts/fetch_test_data.sh

# Configure CMake
cmake -B /workspace/build \
    -DCMAKE_BUILD_TYPE=Release \
    -DPython3_EXECUTABLE=$(which python3) \
    -Dpybind11_DIR=$(python3 -m pybind11 --cmakedir) \
    -DWITH_CERES=ON \
    -DWITH_PYTHON=ON

# Build
cmake --build /workspace/build --config Release

# Info
/workspace/build/bin/rtabmap-console --version

# Test
cd /workspace/build
ctest -C Release --output-on-failure
ctest -C Release --output-on-failure --rerun-failed