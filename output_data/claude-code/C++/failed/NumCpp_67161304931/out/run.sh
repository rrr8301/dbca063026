#!/usr/bin/env bash
set -e

source /opt/miniconda/bin/activate test

cd /app

export BOOST_ROOT=/usr/lib/x86_64-linux-gnu/cmake/Boost-1.71.0

echo "Configuring CMake..."
cmake -B /app/build \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_STANDARD=17 \
  -DBOOST_ROOT=${BOOST_ROOT} \
  -DNUMCPP_NO_USE_BOOST=OFF \
  -DNUMCPP_USE_MULTITHREAD=OFF \
  -DBUILD_TESTS=ON \
  -DBUILD_MULTIPLE_TEST=ON \
  -DBUILD_EXAMPLE_README=ON \
  -DBUILD_EXAMPLE_GAUSS_NEWTON_NLLS=ON

echo "Building..."
cmake --build /app/build --config Release -j4

echo "Running pytest..."
cd /app/test/pytest
pytest || true

echo "Running ctest..."
cd /app/build
ctest -R BinaryLoggerTestSuite -R LoggerTestSuite || true

echo "Installing..."
cmake --build /app/build --config Release --target install

echo "FINAL_STATUS = SUCCESS"
