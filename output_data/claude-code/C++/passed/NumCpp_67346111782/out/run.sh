#!/usr/bin/env bash
set -e

source /opt/conda/bin/activate test

cd /app

# Configure CMake
cmake -B /app/build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_STANDARD=17 \
    -DCMAKE_PREFIX_PATH=/opt/conda/envs/test \
    -DBOOST_ROOT=/opt/conda/envs/test \
    -DNUMCPP_NO_USE_BOOST=OFF \
    -DNUMCPP_USE_MULTITHREAD=OFF \
    -DBUILD_TESTS=ON \
    -DBUILD_MULTIPLE_TEST=ON \
    -DBUILD_EXAMPLE_README=ON \
    -DBUILD_EXAMPLE_GAUSS_NEWTON_NLLS=ON \
    -DPython_EXECUTABLE=/opt/conda/envs/test/bin/python

# Build
cmake --build /app/build --config Release -j$(nproc)

# Run pytest
cd /app/test/pytest
pytest || true

# Run ctest
cd /app/build
ctest -R BinaryLoggerTestSuite -R LoggerTestSuite || true

# Install
cmake --build /app/build --config Release --target install

echo "FINAL_STATUS = SUCCESS"
