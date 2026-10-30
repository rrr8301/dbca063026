#!/bin/bash

set -e

# Navigate to workspace
cd /workspace

# Checkout submodules (simulate actions/checkout with submodules: true)
git submodule update --init --recursive

# Remove default build config
rm -fv dmlc-core/include/dmlc/build_config_default.h || true

# Configure the system for sanitizers
export ASAN_SYMBOLIZER_PATH=/usr/bin/llvm-symbolizer
export ASAN_OPTIONS=symbolize=1
export UBSAN_OPTIONS=print_stacktrace=1:log_path=ubsan_error.log

# Set sysctl for sanitizers (may require --privileged in docker run)
sysctl vm.mmap_rnd_bits=28 || true

# Build and test
bash ops/pipeline/build-cpu.sh cpu-sanitizer

echo "Build and test completed successfully"