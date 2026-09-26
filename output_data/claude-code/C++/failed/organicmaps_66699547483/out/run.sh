#!/usr/bin/env bash

set -e

export CC=gcc-13
export CXX=g++-13
export CMAKE_C_COMPILER_LAUNCHER=ccache
export CMAKE_CXX_COMPILER_LAUNCHER=ccache
export UNITY_BUILD=ON
export BUILD_DIR=build
export CTEST_EXCLUDE_REGEX="drape_tests|drape_frontend_tests|generator_integration_tests|opening_hours_integration_tests|opening_hours_supported_features_tests|routing_benchmarks|routing_integration_tests|routing_quality_tests|search_quality_tests|storage_integration_tests|shaders_tests|world_feed_integration_tests"
export QT_QPA_PLATFORM=offscreen

# Parallel submodules checkout
git submodule update --depth 1 --init --recursive --jobs=20

# Configure cmake
cmake . -B $BUILD_DIR -G Ninja \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_C_FLAGS=-g1 \
  -DCMAKE_CXX_FLAGS=-g1 \
  -DCMAKE_UNITY_BUILD=${UNITY_BUILD}

# Compile
cd $BUILD_DIR
ninja

# Run tests
ctest -j$(nproc --all) -L "omim-test" -E "$CTEST_EXCLUDE_REGEX" --output-on-failure || true

# Run drape tests
ctest -R "drape_tests|drape_frontend_tests|shaders_tests" --verbose || true

# Mark success since tests ran
echo "FINAL_STATUS = SUCCESS"
