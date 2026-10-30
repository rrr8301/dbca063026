#!/bin/bash

# Activate environment
source /etc/profile

# Configure CMake
cmake -B /workspace/build -DCMAKE_BUILD_TYPE=Release -DPython3_EXECUTABLE=$(which python3) -Dpybind11_DIR=$(python3 -m pybind11 --cmakedir) -DWITH_CERES=ON -DWITH_PYTHON=ON

# Build the project
cmake --build /workspace/build --config Release

# Run tests
cd /workspace/build
ctest -C Release --output-on-failure
ctest -C Release --output-on-failure --rerun-failed