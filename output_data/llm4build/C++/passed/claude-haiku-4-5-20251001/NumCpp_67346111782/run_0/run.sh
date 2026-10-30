#!/bin/bash

set -e

# Initialize conda
source /opt/miniconda/etc/profile.d/conda.sh

# Activate test environment
conda activate test

# Navigate to workspace
cd /workspace

# Configure CMake
cmake -B /workspace/build \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_STANDARD=17 \
  -DBOOST_ROOT=/usr/lib/x86_64-linux-gnu/cmake/Boost-1.71.0 \
  -DNUMCPP_NO_USE_BOOST=OFF \
  -DNUMCPP_USE_MULTITHREAD=false \
  -DBUILD_TESTS=ON \
  -DBUILD_MULTIPLE_TEST=ON \
  -DBUILD_EXAMPLE_README=ON \
  -DBUILD_EXAMPLE_GAUSS_NEWTON_NLLS=ON

# Build
cmake --build /workspace/build --config Release -j88

# Run pytest
cd /workspace/test/pytest
pytest

# Run ctest
cd /workspace/build
ctest -R BinaryLoggerTestSuite -R LoggerTestSuite

# Install
cd /workspace
cmake --build /workspace/build --config Release --target install