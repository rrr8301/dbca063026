#!/bin/bash

# Activate environment variables
export CC=gcc-13
export CXX=g++-13
export CMAKE_C_COMPILER_LAUNCHER=ccache
export CMAKE_CXX_COMPILER_LAUNCHER=ccache
export UNITY_BUILD=ON
export BUILD_DIR=build

# Free disk space
sudo rm -rf /usr/share/dotnet /usr/local/lib/android /opt/ghc

# Checkout sources
git submodule update --depth 1 --init --recursive --jobs=20

# Configure repository
./configure.sh

# Configure cmake
cmake . -B $BUILD_DIR -G Ninja \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_C_FLAGS=-g1 \
  -DCMAKE_CXX_FLAGS=-g1 \
  -DCMAKE_UNITY_BUILD=${UNITY_BUILD}

# Compile
cd $BUILD_DIR
ninja

# Prepare testing environment
sudo locale-gen en_US
sudo locale-gen en_US.UTF-8
sudo locale-gen es_ES
sudo locale-gen es_ES.UTF-8
sudo locale-gen fr_FR
sudo locale-gen fr_FR.UTF-8
sudo locale-gen ru_RU
sudo locale-gen ru_RU.UTF-8
sudo update-locale

# Run tests
CTEST_EXCLUDE_REGEX="drape_tests|generator_integration_tests|opening_hours_integration_tests|opening_hours_supported_features_tests|routing_benchmarks|routing_integration_tests|routing_quality_tests|search_quality_tests|storage_integration_tests|shaders_tests|world_feed_integration_tests"
ctest -L "omim-test" -E "$CTEST_EXCLUDE_REGEX" --output-on-failure