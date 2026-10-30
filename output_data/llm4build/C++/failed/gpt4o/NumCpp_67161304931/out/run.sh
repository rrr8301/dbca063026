#!/bin/bash

# Activate conda environment
source /opt/conda/bin/activate test

# Configure CMake
cmake -B /workspace/build -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_STANDARD=17 -DBOOST_ROOT=/usr/lib/x86_64-linux-gnu/cmake/Boost-1.71.0 -DNUMCPP_NO_USE_BOOST=OFF -DNUMCPP_USE_MULTITHREAD=OFF -DBUILD_TESTS=ON -DBUILD_MULTIPLE_TEST=ON -DBUILD_EXAMPLE_README=ON -DBUILD_EXAMPLE_GAUSS_NEWTON_NLLS=ON

# Build the project
cmake --build /workspace/build --config Release -j88

# Run pytest
cd /workspace/test/pytest
pytest

# Run ctest
cd /workspace/build
ctest -R BinaryLoggerTestSuite -R LoggerTestSuite

# Install the project
cmake --build /workspace/build --config Release --target install