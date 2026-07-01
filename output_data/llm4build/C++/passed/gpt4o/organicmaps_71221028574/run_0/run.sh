#!/bin/bash

# Set environment variables
export BUILD_DIR=build
export CC=gcc-13
export CXX=g++-13

# Checkout submodules
git submodule update --depth 1 --init --recursive --jobs=20

# Configure repository
./configure.sh

# Configure cmake
cmake . -B $BUILD_DIR -G Ninja \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_C_FLAGS=-g1 \
  -DCMAKE_CXX_FLAGS=-g1

# Compile
cd $BUILD_DIR
ninja

# Prepare testing environment
locale-gen en_US.UTF-8 es_ES.UTF-8 fr_FR.UTF-8 ru_RU.UTF-8
update-locale

# Run tests
ctest -j$(nproc --all) -L "omim-test" -E "drape_tests|drape_frontend_tests|generator_integration_tests|opening_hours_integration_tests|opening_hours_supported_features_tests|routing_benchmarks|routing_integration_tests|routing_quality_tests|search_quality_tests|storage_integration_tests|shaders_tests|world_feed_integration_tests" --output-on-failure || true

# Run drape tests
env QT_QPA_PLATFORM="offscreen" ctest -R "drape_tests|drape_frontend_tests|shaders_tests" --verbose || true