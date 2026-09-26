#!/bin/bash

set -e

# Set environment variables for GCC 9
export CC=gcc-9
export CXX=g++-9

# Bazel defines to disable AVX/AVX512 features for GCC 9
export BAZEL_DEFINES="
  --define=xnn_enable_avxvnni=false
  --define=xnn_enable_avx256vnni=false
  --define=xnn_enable_avxvnniint8=false
  --define=xnn_enable_avx512amx=false
  --define=xnn_enable_avx512fp16=false
  --define=xnn_enable_avx512bf16=false
  --define=xnn_enable_avx512vnni=false
  --define=xnn_enable_avx512vnnigfni=false
  --define=xnn_enable_avx512skx=false
  --define=xnn_enable_avx512f=false
  --define=ynn_enable_x86_amx=false
  --define=ynn_enable_x86_avx512=false
"

# Create bazel cache directories
mkdir -p /home/xnnpack/.cache/bazel/disk_cache
mkdir -p /home/xnnpack/.cache/bazel/repo_cache

# Configure ccache
ccache -M 500M
ccache -z

echo "Building and running tests with Bazel (GCC 9)..."

# Build and run tests
bazel test \
  -c opt \
  --disk_cache=/home/xnnpack/.cache/bazel/disk_cache \
  --repository_cache=/home/xnnpack/.cache/bazel/repo_cache \
  --test_output=errors \
  --local_test_jobs=HOST_CPUS \
  ${BAZEL_DEFINES} \
  -- \
  //test/... \
  //bench/... \
  //ynnpack/... \
  -//ynnpack/kernels/dot:get_dot_kernel_test

TEST_RESULT=$?

# Print ccache stats
echo "=== ccache statistics ==="
ccache -s

if [ $TEST_RESULT -ne 0 ]; then
  echo "Tests failed with exit code $TEST_RESULT"
  exit $TEST_RESULT
fi

echo "All tests passed successfully!"
exit 0