#!/bin/bash

set -e

# Environment variables
export BUILD_DIR="build"
export CC="gcc-13"
export CXX="g++-13"
export CMAKE_BUILD_TYPE="Debug"
export CMAKE_C_COMPILER_LAUNCHER="ccache"
export CMAKE_CXX_COMPILER_LAUNCHER="ccache"
export UNITY_BUILD="ON"
export QT_QPA_PLATFORM="offscreen"

# Clone repository (simulating actions/checkout)
if [ ! -d "organicmaps" ]; then
    git clone https://github.com/organicmaps/organicmaps.git
fi
cd organicmaps

# Parallel submodules checkout
echo "Initializing submodules..."
git submodule update --depth 1 --init --recursive --jobs=20

# Configure repository
echo "Running configure.sh..."
./configure.sh

# Configure CMake
echo "Configuring CMake..."
cmake . -B "$BUILD_DIR" -G Ninja \
    -DCMAKE_BUILD_TYPE=Debug \
    -DCMAKE_C_FLAGS=-g1 \
    -DCMAKE_CXX_FLAGS=-g1 \
    -DCMAKE_UNITY_BUILD=ON

# Compile
echo "Compiling with Ninja..."
cd "$BUILD_DIR"
ninja

# Prepare testing environment (locales)
echo "Preparing testing environment..."
locale-gen en_US
locale-gen en_US.UTF-8
locale-gen es_ES
locale-gen es_ES.UTF-8
locale-gen fr_FR
locale-gen fr_FR.UTF-8
locale-gen ru_RU
locale-gen ru_RU.UTF-8
update-locale

# Run tests (excluding specific test suites)
echo "Running ctest with exclusions..."
CTEST_EXCLUDE_REGEX="drape_tests|drape_frontend_tests|generator_integration_tests|opening_hours_integration_tests|opening_hours_supported_features_tests|routing_benchmarks|routing_integration_tests|routing_quality_tests|search_quality_tests|storage_integration_tests|shaders_tests|world_feed_integration_tests"

ctest -j$(nproc --all) -L "omim-test" -E "$CTEST_EXCLUDE_REGEX" --output-on-failure || TEST_RESULT_1=$?

# Run drape tests
echo "Running drape tests..."
ctest -R "drape_tests|drape_frontend_tests|shaders_tests" --verbose || TEST_RESULT_2=$?

# Exit with failure if any test suite failed
if [ -n "$TEST_RESULT_1" ] || [ -n "$TEST_RESULT_2" ]; then
    echo "Some tests failed!"
    exit 1
fi

echo "All tests completed successfully!"
exit 0