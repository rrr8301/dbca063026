#!/bin/bash

set -e

# Set environment variables
export BUILD_DIR=build
export CC=gcc-13
export CXX=g++-13
export CMAKE_C_COMPILER_LAUNCHER=ccache
export CMAKE_CXX_COMPILER_LAUNCHER=ccache
export UNITY_BUILD=ON

# Free disk space (optional but included for completeness)
echo "Freeing disk space..."
rm -rf /usr/share/dotnet /usr/local/lib/android /opt/ghc 2>/dev/null || true

# Checkout sources (already in container, but ensure we're in the right directory)
cd /workspace

# Parallel submodules checkout
echo "Updating git submodules..."
git submodule update --depth 1 --init --recursive --jobs=20

# Configure repository with explicit compiler specification
echo "Running configure.sh..."
./configure.sh --cxx=g++-13

# Configure ccache
echo "Configuring ccache..."
ccache --max-size=5G

# Configure cmake
echo "Configuring CMake..."
cmake . -B $BUILD_DIR -G Ninja \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_C_FLAGS=-g1 \
  -DCMAKE_CXX_FLAGS=-g1 \
  -DCMAKE_UNITY_BUILD=ON

# Compile
echo "Compiling with Ninja..."
cd $BUILD_DIR
ninja

# Prepare testing environment
echo "Preparing testing environment..."
cd /workspace

# Run tests (excluding specified test suites as per YAML)
echo "Running ctest with exclusions..."
export CTEST_EXCLUDE_REGEX="drape_tests|generator_integration_tests|opening_hours_integration_tests|opening_hours_supported_features_tests|routing_benchmarks|routing_integration_tests|routing_quality_tests|search_quality_tests|storage_integration_tests|shaders_tests|world_feed_integration_tests"
cd $BUILD_DIR
ctest -L "omim-test" -E "$CTEST_EXCLUDE_REGEX" --output-on-failure

# Run drape tests
echo "Running drape tests..."
export QT_QPA_PLATFORM="offscreen"
ctest -R drape_tests --output-on-failure

echo "All tests passed!"
exit 0