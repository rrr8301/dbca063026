#!/usr/bin/env bash

set -e

cd /app

# Set up Bazel cache directories
mkdir -p /home/xnnpack/.cache/bazel/disk_cache
mkdir -p /home/xnnpack/.cache/bazel/repo_cache

# Define the Bazel flags that disable certain features for gcc-9
BAZEL_DEFINES="--define=xnn_enable_avxvnni=false \
--define=xnn_enable_avx256vnni=false \
--define=xnn_enable_avxvnniint8=false \
--define=xnn_enable_avx512amx=false \
--define=xnn_enable_avx512fp16=false \
--define=xnn_enable_avx512bf16=false \
--define=xnn_enable_avx512vnni=false \
--define=xnn_enable_avx512vnnigfni=false \
--define=xnn_enable_avx512skx=false \
--define=xnn_enable_avx512f=false \
--define=ynn_enable_x86_amx=false \
--define=ynn_enable_x86_avx512=false"

# Run the bazel tests
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
  //litert/... \
  -//ynnpack/kernels/dot:get_dot_kernel_test

if [ $? -eq 0 ]; then
  echo "FINAL_STATUS = SUCCESS"
  exit 0
else
  echo "FINAL_STATUS = FAIL"
  exit 1
fi
