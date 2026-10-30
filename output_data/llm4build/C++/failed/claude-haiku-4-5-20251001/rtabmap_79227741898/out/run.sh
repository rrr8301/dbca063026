#!/bin/bash
set -e

# Fetch test data
bash scripts/fetch_test_data.sh

# Configure CMake
cmake -B build \
  -DCMAKE_BUILD_TYPE=Release \
  -DPython3_EXECUTABLE=$(which python3) \
  -Dpybind11_DIR=$(python3 -m pybind11 --cmakedir) \
  -DWITH_CERES=ON \
  -DWITH_PYTHON=ON

# Build
cmake --build build --config Release

# Info
./build/bin/rtabmap-console --version

# Test
cd build
export PYTHONNOUSERSITE=1
ctest -C Release --output-on-failure
ctest -C Release --output-on-failure --rerun-failed