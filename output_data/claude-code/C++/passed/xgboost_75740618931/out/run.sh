#!/usr/bin/env bash
set -euox pipefail

# Configure the system for sanitizers
export ASAN_SYMBOLIZER_PATH=/usr/bin/llvm-symbolizer
export ASAN_OPTIONS=symbolize=1
export UBSAN_OPTIONS=print_stacktrace=1:log_path=ubsan_error.log

# Work around https://github.com/google/sanitizers/issues/1614
sysctl vm.mmap_rnd_bits=28 || true

# Remove default build config to ensure CMake-configured header is used
rm -fv dmlc-core/include/dmlc/build_config_default.h

# Run the build and test
bash ops/pipeline/build-cpu.sh cpu-sanitizer

echo "FINAL_STATUS = SUCCESS"
