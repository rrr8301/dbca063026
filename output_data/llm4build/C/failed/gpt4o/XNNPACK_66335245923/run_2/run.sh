#!/bin/bash

# Clone the repository
git clone https://github.com/your/repo.git /workspace
cd /workspace

# Set environment variables
export CC=gcc-9
export CXX=g++-9
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

# Build and run tests
bazel test \
  -c opt \
  --disk_cache=/home/xnnpack/.cache/bazel/disk_cache \
  --repository_cache=/home/xnnpack/.cache/bazel/repo_cache \
  --test_output=errors \
  --local_test_jobs=$(nproc) \
  ${BAZEL_DEFINES} \
  -- \
  //test/... \
  //bench/... \
  //ynnpack/...